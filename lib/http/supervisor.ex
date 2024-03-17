defmodule Http.Supervisor do
  use Supervisor;
  require Logger

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    port = String.to_integer(Application.fetch_env!(:spectral, :port))
    Logger.info("Listening on :#{port}")

    children = [
      {Task.Supervisor, name: Http.TaskSupervisor},
      {
        Bandit,
        plug: Httpqueue.Http.Listener,
        port: port
      },
      Http.Handler,
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
