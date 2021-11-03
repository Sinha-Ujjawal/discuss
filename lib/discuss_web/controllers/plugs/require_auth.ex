defmodule DiscussWeb.Plugs.RequireAuth do
  use DiscussWeb, :controller

  def init(_params) do
  end

  def call(conn = %{assigns: %{user: user}}, _params) do
    if user do
      conn
    else
      conn
      |> put_flash(:error, "Not Authorized!")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt
    end
  end
end
