defmodule Mazurka.Mixfile do
  use Mix.Project

  def project do
    [app: :mazurka,
     version: "1.0.5",
     elixir: "~> 1.0",
     description: "hypermedia api toolkit",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.circle": :test,
       "coveralls.detail": :test,
       "coveralls.html": :test
     ],
     package: package(),
     deps: deps(),
     docs: [extra_section: "Guide",
            extras: examples()]]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:mimetype_parser, "~> 0.1.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:excoveralls, "~> 0.5.1", only: :test},]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/exstruct/mazurka"}]
  end

  def examples() do
    if Mix.env == :dev do
      ["extra/GETTING_STARTED.md",
       "extra/Overview.md",
       "extra/Installation.md",
       "extra/Mediatype.md",
       "extra/Affordance.md",
       "extra/Param_Input_and_Option.md",
       "extra/Condition_and_Validation.md",
       "extra/EXAMPLES.md"
       | Path.wildcard("testdoc/**/*.md")]
    else
      []
    end
  end
end
