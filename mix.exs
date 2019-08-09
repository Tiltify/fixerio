defmodule Fixerio.MixProject do
  use Mix.Project

  def project do
    [
      app: :fixerio,
      version: "0.1.0",
      description: description(),
      package: package(),
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Fixerio",
      source_url: "https://github.com/sajan45/fixerio",
      homepage_url: "https://github.com/sajan45/fixerio",
      docs: [
        main: "Fixerio", # The main page in the docs
        extras: ["README.md"]
      ]
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
      {:httpoison, "~> 1.5"},
      {:jason, ">= 1.1.0"},
      {:ex_doc, "~> 0.21.0", only: :dev}
    ]
  end

  defp description do
    """
    Convert Money Amounts between currencies. Using any fixer.io compatible API.
    """
  end

  defp package do
    [
      name: :fixerio,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Sajan Sahu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sajan45/fixerio"}
    ]
  end
end
