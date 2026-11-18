defmodule Songbook.MixProject do
  use Mix.Project

  def project do
    [
      app: :songbook,
      version: "0.1.0",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      consolidate_protocols: Mix.env() != :dev
    ]
  end

  def cli do
    [
      preferred_envs: [
        ci: :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Songbook.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:usage_rules, "~> 1.3", only: [:dev]},
      {:sourceror, "~> 1.8", only: [:dev, :test]},
      {:ash_postgres, "~> 2.6"},
      {:ash_phoenix, "~> 2.3"},
      {:ash, "~> 3.11"},
      {:bandit, "~> 1.10"},
      {:cors_plug, "~> 3.0"},
      {:dns_cluster, "~> 0.2"},
      {:ecto_sql, "~> 3.13"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:finch, "~> 0.20"},
      {:floki, "~> 0.38", only: :test},
      {:gettext, "~> 1.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons", tag: "v2.1.1", sparse: "optimized", app: false, compile: false, depth: 1},
      {:jason, "~> 1.4"},
      {:lazy_html, "~> 0.1.6"},
      {:mime, "~> 2.0.6"},
      {:mimic, "~> 2.0", only: :test},
      {:phoenix, "~> 1.8"},
      {:phoenix_ecto, "~> 4.7"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_dashboard, "~> 0.9"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:phoenix_live_view, "~> 1.1"},
      {:postgrex, "~> 0.21"},
      {:req, "~> 0.5"},
      {:swoosh, "~> 1.20"},
      {:styler, "~> 1.10"},
      {:tailwind, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.1"},
      {:telemetry_poller, "~> 1.3"},
      {:tidewave, "~> 0.5", only: :dev},
      {:tzdata, "~> 1.1"},
      {:igniter, "~> 0.7", only: [:dev, :test]},
      {:oban, "~> 2.20"},
      {:image, "~> 0.62"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind songbook", "esbuild songbook"],
      "assets.deploy": [
        "tailwind songbook --minify",
        "esbuild songbook --minify",
        "phx.digest"
      ],
      ci: ["format --check-formatted", "credo --strict", "test"],
      release: ["compile", "assets.deploy", "release"]
    ]
  end
end
