defmodule Spectral do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Staring node #{Node.self()}")

    children = [
      Balancer.Supervisor,
      Http.Supervisor,
      {Cluster.Supervisor, [get_topologies!(), [name: Spectral.ClusterSupervisor]]},
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Spectral.Supervisor)
  end

  defp get_topologies!() do
    case Application.fetch_env!(:spectral, :cluster_algo) do
      "GOSSIP" -> [
        gossip: [
          strategy: Cluster.Strategy.Gossip,
        ]
      ]
      "KUBERNETES_DNS" -> [
        k8s: [
          strategy: Cluster.Strategy.Kubernetes.DNS,
          config: [
            service: Application.fetch_env!(:spectral, :kubernetes_service),
            application_name: Application.fetch_env!(:spectral, :kubernetes_app),
            polling_interval: String.to_integer(Application.fetch_env!(:spectral, :kubernetes_poll_interval)),
          ],
        ]
      ]
      _ -> raise "Invalid Cluster Topology"
    end
  end
end
