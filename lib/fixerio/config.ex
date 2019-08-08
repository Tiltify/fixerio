defmodule Fixerio.Config do

  def default_api do
    Application.get_env(:fixerio, :default_api)
  end

  def fallback_api do
    Application.get_env(:fixerio, :fallback_api)
  end
end