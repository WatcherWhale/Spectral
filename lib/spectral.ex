defmodule Spectral do
  use Application

  def start(_type, _args) do
    topologies = [
      gossip: [
        strategy: Cluster.Strategy.Gossip,
      ]
    ]

    children = [
      Balancer.Supervisor,
      Http.Supervisor,
      {Cluster.Supervisor, [topologies, [name: Spectral.ClusterSupervisor]]},
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Spectral.Supervisor)
  end
end
