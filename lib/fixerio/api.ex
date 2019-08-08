defmodule Fixerio.API do
  alias Fixerio.Config

  def request(method, options \\ []) do
    method
    |> build_url(options)
    |> HTTPoison.get()
    |> handle_response
  end

  def build_url(method, options) do
    end_point = if options[:url] == nil do
      Config.default_api[:url]
    else
      options[:url]
    end

    end_point <> "/api" <> "/" <> method <> build_params(method, options)
  end

  def build_params(method, options) do
    params = "?"
    params = if options[:api_key] == nil do
      params <> "/" <> "access_key=" <> Config.default_api[:api_key]
    else
      params <> "/" <> "access_key=" <> options[:api_key]
    end
    params = case method do
      "convert" ->
        params <> "&from=" <> options[:from] <> "&to=" <> options[:to] <> "&amount=" <> options[:amount]
      # by default we consider any other value to be date or "latest"
      # both have same params requirement
      _ ->
        params <> "&base=" <> options[:base] <> "&symbols=" <> options[:symbols]
    end
    params
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        handle_result(body)
      {:ok, %HTTPoison.Response{status_code: _}} ->
        {:error, "not found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def handle_result(body) do
    data = Jason.decode(body)
    if data["error"] || !data["rates"] do
      error = data["error"]["info"]
      error = if error, do: error, else: ""
      reason = "Error. " <> error
      {:error, reason}
    else
      {:ok, %{base: data["base"], rates: data["rates"]}}
    end
  end
end
