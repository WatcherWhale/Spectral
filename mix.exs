defmodule Spectral.MixProject do
  use Mix.Project

  def project do
    [
      app: :spectral,
      version: "0.0.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Spectral, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:bandit, "~> 1.0"},
      {:httpoison, "~> 2.0"},
    ]
  end
end
