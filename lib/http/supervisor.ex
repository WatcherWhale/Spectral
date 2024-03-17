defmodule Http.Supervisor do
  use Supervisor;

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    port = Enum.random([8001, 8002, 8003, 8004, 8005, 8006])
    IO.puts(port)
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
