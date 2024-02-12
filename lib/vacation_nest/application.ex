defmodule VacationNest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      VacationNestWeb.Telemetry,
      # Start the Ecto repository
      VacationNest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: VacationNest.PubSub},
      # Start Finch
      {Finch, name: VacationNest.Finch},
      # Start the Endpoint (http/https)
      VacationNestWeb.Endpoint
      # Start a worker by calling: VacationNest.Worker.start_link(arg)
      # {VacationNest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VacationNest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VacationNestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
