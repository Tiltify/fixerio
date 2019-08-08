defmodule Fixerio do
  import Fixerio.API

  def get_latest(options \\ %{}) do
    request("latest", options)
  end

  def convert(amount, from, to) do
    options = %{amount: amount, from: from, to: to}
    request("convert", options)
  end

  def historical_data(date, options \\ %{}) do
    request(date, options)
  end
end
