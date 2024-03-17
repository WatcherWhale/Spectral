import Config

config :spectral,
  port: System.get_env("PORT", "8000"),

  cluster_algo: System.get_env("CLUSTER_ALGO", "KUBERNETES_DNS"),

  kubernetes_service: System.get_env("KUBERNETES_SERVICE", ""),
  kubernetes_app: System.get_env("KUBERNETES_APP", ""),
  kubernetes_poll_interval: System.get_env("KUBERNETES_POLL_INTERVAL", "5000")
