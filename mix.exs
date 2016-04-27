defmodule Mazurka.Mixfile do
  use Mix.Project

  def project do
    [app: :mazurka,
     version: "0.3.34",
     elixir: "~> 1.0",
     description: "hypermedia api toolkit",
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:plug, "~> 1.0"},
     {:mimetype_parser, "~> 0.1.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mazurka/mazurka"}]
  end
end
