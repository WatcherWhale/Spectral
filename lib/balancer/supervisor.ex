defmodule Balancer.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      Balancer.Queue,
      Balancer.Node,
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
