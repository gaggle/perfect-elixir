defmodule PluggedCowboy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Connect  Plug.Cowboy plug handler
      {Plug.Cowboy, plug: PluggedCowboy.MyPlug, scheme: :http,
        options: [port: 8080]}
      # Starts a worker by calling: PluggedCowboy.Worker.start_link(arg)
      # {PluggedCowboy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PluggedCowboy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end