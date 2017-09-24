defmodule Submarine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :submarine,
      version: "0.0.2",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp description do
    "a small pubsub solution"
  end

  defp package() do
  [
    maintainers: ["James Steinmetz"],
    licenses: ["Apache 2.0"],
    links: %{"GitHub" => "https://github.com/j-peso/Submarine"}
  ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
