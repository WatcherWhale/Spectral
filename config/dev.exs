import Config

config :spectral,
  port: System.get_env("PORT", "8000"),
  cluster_algo: System.get_env("CLUSTER_ALGO", "GOSSIP")
