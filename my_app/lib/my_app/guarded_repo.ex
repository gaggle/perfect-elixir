defmodule MyApp.GuardedRepo do
  @moduledoc """
  * `GuardedRepo`: This is the public interface. It also manages child processes: `StateManager` & `RepoSupervisor`.
  * `StateManager`: Holds guard-state, including a "circuit breaker" status that's `:closed` when the database is available, and `:open` when unavailable.
  * `RepoSupervisor`: Supervisor that "firewalls" the Ecto repo process so the repo can crash (when database becomes unavailable) without affecting `GuardedRepo` functionality. It manages child processes: `RepoStarter` & `RepoObserver`
  * `RepoStarter`: A simple wrapper to start the Ecto repo and signal to `StateManager` if the repo managed to start (because Ecto repos crash if no database is available)
  * `RepoObserver`: This monitors the Ecto repo process, and if it crashes it notifies `StateManager`
  """

  use Supervisor

  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)

  def query(sql, params \\ [], opts \\ []) do
    case status() do
      :closed ->
        repo = __MODULE__.StateManager |> Process.whereis() |> GenServer.call(:get_repo)
        repo.query(sql, params, opts)

      :open ->
        {:error, :open}
    end
  end

  def attempt_circuit_close do
    case status() do
      :closed ->
        {:error, :already_closed}

      :open ->
        :ok = Supervisor.terminate_child(__MODULE__, __MODULE__.RepoSupervisor)
        {:ok, _pid} = Supervisor.restart_child(__MODULE__, __MODULE__.RepoSupervisor)
    end
  end

  def status, do: __MODULE__.StateManager |> Process.whereis() |> GenServer.call(:get_status)

  @impl Supervisor
  def init(args) do
    repo = Keyword.get(args, :repo)

    children = [
      {__MODULE__.StateManager, repo: repo},
      %{
        id: __MODULE__.RepoSupervisor,
        start: {__MODULE__.RepoSupervisor, :start_link, [[repo: repo]]},
        restart: :permanent
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule MyApp.GuardedRepo.StateManager do
  use GenServer

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(args) do
    repo = Keyword.get(args, :repo)
    {:ok, %{repo: repo, status: :open}}
  end

  @impl true
  def handle_call(:get_repo, _from, state), do: {:reply, state.repo, state}
  @impl true
  def handle_call(:get_status, _from, state), do: {:reply, state.status, state}
  @impl true
  def handle_call(:close_circuit, _from, state), do: {:reply, :ok, %{state | status: :closed}}
  @impl true
  def handle_call(:open_circuit, _from, state), do: {:reply, :ok, %{state | status: :open}}
end

defmodule MyApp.GuardedRepo.RepoSupervisor do
  use Supervisor

  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(args) do
    repo = Keyword.get(args, :repo)

    children = [
      MyApp.GuardedRepo.RepoObserver,
      %{
        id: MyApp.GuardedRepo.RepoStarter,
        start: {MyApp.GuardedRepo.RepoStarter, :start_link, [[repo: repo]]},
        restart: :temporary
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule MyApp.GuardedRepo.RepoStarter do
  use GenServer

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do
    repo = Keyword.get(args, :repo)

    case repo.start_link() do
      {:ok, pid} ->
        MyApp.GuardedRepo.RepoObserver
        |> Process.whereis()
        |> GenServer.call({:start_monitoring, pid})

        MyApp.GuardedRepo.StateManager |> Process.whereis() |> GenServer.call(:close_circuit)
        {:ok, :started}

      {:error, reason} ->
        MyApp.GuardedRepo.StateManager |> Process.whereis() |> GenServer.call(:open_circuit)
        {:error, reason}
    end
  end
end

defmodule MyApp.GuardedRepo.RepoObserver do
  use GenServer

  def start_link(_no_args \\ []), do: GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)

  @impl true
  def init(_args), do: {:ok, %{monitoring_started: false, monitor_ref: nil, repo_pid: nil}}
  @impl true
  def handle_call({:start_monitoring, repo_pid}, _from, state),
    do:
      {:reply, :ok,
       %{
         state
         | monitoring_started: true,
           monitor_ref: repo_pid |> Process.monitor(),
           repo_pid: repo_pid
       }}

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    MyApp.GuardedRepo.StateManager |> Process.whereis() |> GenServer.call(:open_circuit)
    {:noreply, %{state | repo_pid: nil}}
  end
end
