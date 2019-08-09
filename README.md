# Fixerio

An API wrapper for Fixer.io compatible APIs for currency conversation rates.
It supports multiple endpoint in configuration so that these can be used as fallback endpoints. This is helpful if you hit your API call limit of a provider, in this case you can use some other provider or use own API.

There are API providers like https://exchangeratesapi.io and https://ratesapi.io which provides free API with limited currency than the Fixer.io . Or you can use own hosted API if you have other data sources.

## Installation

The package can be installed by adding `fixerio` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fixerio, "~> 0.1.0"}
  ]
end
```

In your `config.exs` file, add a configuration for your default API and fallback APIs like below:

```
config :fixerio,
  default_api: [url: "https://own-api.herokuapp.com", api_key: ""],
  fallback_apis: [[url: "https://api.ratesapi.io", api_key: ""], [url: "http://data.fixer.io", api_key: "API_KEY"]]
```

`api_key` value can be an empty string. If there is an API key for an endpoint then it will be used to make API calls, otherwise API calls will be made without using any key. Please make sure that you have provided API key for all endppoints that mandatorily needs it.

## Usage

Please refer the [documentation](https://hexdocs.pm/fixerio) for the API usage.
