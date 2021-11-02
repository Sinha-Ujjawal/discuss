defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  plug(Ueberauth)
  alias Discuss.User
  alias Discuss.Repo

  def callback(conn = %{assigns: %{user: user}}, _params) when not is_nil(user) do
    conn
    |> put_flash(:info, "Already signed in!")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  # callback for OAuth
  def callback(conn = %{assigns: %{ueberauth_auth: auth, user: user}}, _params)
      when is_nil(user) do
    user_params = %{
      email: auth.info.email,
      provider: auth.provider |> Atom.to_string(),
      token: auth.credentials.token
    }

    changeset = User.changeset(%User{}, user_params)
    signin(conn, user_params, changeset)
  end

  defp signin(conn, user_params, changeset) do
    case upsert_user(user_params, changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error signing in")
    end
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  defp upsert_user(user_params, changeset) do
    case Repo.get_by(User, email: user_params.email) do
      nil ->
        Repo.insert(changeset)

      user ->
        Repo.update(user |> User.changeset(user_params))
    end
  end

  def signout(conn = %{assigns: %{user: user}}, _params) do
    if user == nil do
      conn
      |> put_flash(:error, "Not signed in")
    else
      conn
      |> configure_session(drop: true)
    end
    |> redirect(to: Routes.topic_path(conn, :index))
  end
end
