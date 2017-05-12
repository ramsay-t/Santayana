defmodule Santayana.Mixfile do
  use Mix.Project

  def project do
    [app: :santayana,
     version: "0.1.0",
     elixir: "~> 1.4-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,:httpoison,:timex],
		 mod: {Santayana, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:skel, git: "https://github.com/ramsay-t/skel", override: true},
		 {:elgar, git: "https://github.com/ramsay-t/elgar", compile: "mkdir -p deps; ln -s ../../skel deps/skel; rebar compile"},
		 {:json, git: "https://github.com/cblage/elixir-json/"},
		 {:logger_file_backend, ">= 0.0.4"},
		 {:timex, "~> 3.0"},
		 {:httpoison, "~> 0.10.0"},
		 {:ex_doc, "~> 0.14", only: :dev, runtime: false}
		]
  end
end
