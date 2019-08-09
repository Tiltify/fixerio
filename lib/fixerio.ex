defmodule Fixerio do
  import Fixerio.API
  alias Fixerio.Config

  def get_latest(options \\ %{base: :EUR}) do
    base = if options[:base], do: options[:base], else: :USD
    options = Map.put(options, :base, base)
    request_with_fallback("latest", options)
  end

  def convert(amount, from, to) do
    options = %{amount: amount, from: from, to: to}
    request("convert", options)
  end

  def historical_data(date, options \\ %{base: :EUR}) do
    base = if options[:base], do: options[:base], else: :USD
    options = Map.put(options, :base, base)
    date = Date.to_string(date)
    request_with_fallback(date, options)
  end

  def get_currencies do
    # hard coded currecncies list
    # thsi does not included extra currency data provided by fixer.io
    [:USD,:AED,:ARS,:AUD,:BGN,:BRL,:BSD,:CAD,:CHF,:CLP,:CNY,:COP,:CZK,:DKK,:DOP,:EGP,:EUR,:FJD,:GBP,:GTQ,:HKD,:HRK,:HUF,:IDR,:ILS,:INR,:ISK,:JPY,:KRW,:KZT,:MXN,:MYR,:NOK,:NZD,:PAB,:PEN,:PHP,:PKR,:PLN,:PYG,:RON,:RUB,:SAR,:SEK,:SGD,:THB,:TRY,:TWD,:UAH,:UYU,:VND,:ZAR]
  end

  defp request_with_fallback(method, options) do
    case request(method, options) do
      {:ok, data} ->
        {:ok, data}
      {:error, reason} ->
        error_lists = [%{url: Config.default_api[:url], reason: reason}]
        result = Enum.reduce_while(Config.fallback_apis, [], fn api, err_list ->
          options = Map.merge(options, %{url: api[:url], api_key: api[:api_key]})
          case request(method, options) do
            {:ok, data} ->
              {:halt, {:ok, data}}
            {:error, reason} ->
              err_list = err_list ++ [%{url: options[:url], reason: reason}]
              {:cont, err_list}
          end
        end)
        case result do
          {:ok, data} ->
            {:ok, data}
          [h | t] ->
            errors = error_lists ++ [h | t]
            {:error, %{errors: errors}}
          _ ->
            {:error, %{errors: [%{url: "all", reason: "Something went wrong"}]}}
        end
    end
  end
end
