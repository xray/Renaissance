defmodule Renaissance.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Renaissance.Repo,
      # Start the endpoint when the application starts
      RenaissanceWeb.Endpoint
      # Starts a worker by calling: Renaissance.Worker.start_link(arg)
      # {Renaissance.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Renaissance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RenaissanceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
