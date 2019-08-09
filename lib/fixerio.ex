defmodule Fixerio do
  @moduledoc """
  Provides access to Fixer.io like API with support for multiple endpoint
  to use as fallback.
  """
  import Fixerio.API
  alias Fixerio.Config

  @doc """
  Gets the latest conversion rates. Uses the `/latest` API endpoint.

  parameters:
    * `options` (optioal): Map with optional keys `base` and  `symbols`

  Returns:
    `%{ base: "USD", date: "2019-08-09", rates: %{ "AUD" => 1.46, "CZK" => 23.064, "IDR" => 14189.998, ... }}` in case of success
    `{:error, %{errors: []}` in case of failure
  ## Examples
    iex> Fixerio.get_latest %{base: :USD}
    {:ok,
    %{
      base: "USD",
      date: "2019-08-09",
      rates: %{
        "AUD" => 1.469190927,
        "CZK" => 23.0648330059,
        "IDR" => 14189.9982139668,
        .
        .
        .
      }
    }}

    iex> Fixerio.get_latest %{base: :USD}
    {:error,
    %{
      errors: [
        %{reason: "not found", url: "https://my-api.herokuapp.com"},
        %{
          reason: "Error. base_currency_access_restricted",
          url: "http://data.fixer.io"
        }
      ]
    }}

    iex> Fixerio.get_latest(%{symbols: [:AUD, :BRL, :CNY]})
    {:ok,
    %{
      base: "USD",
      date: "2019-08-09",
      rates: %{"AUD" => 1.469190927, "BRL" => 3.9287372745, "CNY" => 7.0583139846}
    }}
  """
  def get_latest(options \\ %{base: :EUR}) do
    base = if options[:base], do: options[:base], else: :USD
    options = Map.put(options, :base, base)
    request_with_fallback("latest", options)
  end

  @doc """
  Coverts the given amount from the `from` currency to `to` currency, optionally
  based on rate of a specific day.

  parameters:
    * `amount` (required): Integer - the amount to be converted
    * `from` (required): Atom - current currency of the amount
    * `to` (required): Atom - converted currency of the amount
    * `date` (optional): Date - rate of the day to be used

  Returns:
    below data format in case of success
    ```
    {:ok,
      %{
        date: "2019-08-09",
        info: %{rate: 0.8930166101, timestamp: 1565380266},
        query: %{amount: 90000, from: :USD, to: :EUR},
        result: 80371.494909
      }
    }
    ```
    or

    `{:error, "Failed. No API available."}` in case of failure
  ## Examples
    iex> Fixerio.convert(90000, :USD, :EUR)
    {:ok,
    %{
      date: "2019-08-09",
      info: %{rate: 0.8930166101, timestamp: 1565380266},
      query: %{amount: 90000, from: :USD, to: :EUR},
      result: 80371.494909
    }}
  """
  def convert(amount, from, to, date \\ nil) do
    method = if date, do: Date.to_string(date), else: "latest"
    options = %{base: from, symbols: [to]}
    to_in_str = Atom.to_string(to)
    case request_with_fallback(method, options) do
      {:ok, %{date: date, rates: %{^to_in_str => rate}}} ->
        data = %{
          query: %{
            from: from,
            to: to,
            amount: amount
          },
          info: %{
            timestamp: DateTime.utc_now |> DateTime.to_unix(),
            rate: rate
          },
          date: date,
          result: amount * rate
        }
        {:ok, data}
      {:error, _} ->
        {:error, "Failed. No API available."}
    end
  end

  @doc """
  Gets the conversion rates on a day in past.

  parameters:
    * `date` (required): Date
    * `options` (optioal): Map with optional keys `base` and  `symbols`

  Returns:
    `%{ base: "USD", date: "2019-08-09", rates: %{ "AUD" => 1.46, "CZK" => 23.064, "IDR" => 14189.998, ... }}` in case of success
    `{:error, %{errors: []}` in case of failure
  ## Examples
    iex> Fixerio.historical_data(Date.utc_today)
    {:ok,
    %{
      base: "EUR",
      date: "2019-08-09",
      rates: %{
        "AUD" => 1.6452,
        "BGN" => 1.9558,
        "BRL" => 4.3994,
        .
        .
        .
      }
    }}
  """
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
