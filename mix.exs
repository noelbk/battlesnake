defmodule Battlesnake.Mixfile do
  use Mix.Project

  def project do
    [app: :battlesnake,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :gproc, :erlexec]]
  end

  defp deps do
		[
				{:erlexec, "~> 1.6"},
				{:gproc, "~> 0.3.1"},
		]
  end
end
