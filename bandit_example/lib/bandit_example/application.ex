defmodule BanditExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: BanditExample.MyPlug, port: 8080},
      {Postgrex,
        [
          name: :bandit_db,
          hostname: "localhost",
          username: "bandit",
          password: "bandit",
          database: "bandit"
        ]
      }
      # Starts a worker by calling: BanditExample.Worker.start_link(arg)
      # {BanditExample.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BanditExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
