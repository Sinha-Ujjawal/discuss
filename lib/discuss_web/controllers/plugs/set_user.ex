defmodule DiscussWeb.Plugs.SetUser do
  use DiscussWeb, :controller
  alias Discuss.Repo
  alias Discuss.User

  def init(_params) do
  end

  def call(conn, _params) do
    # here _params is different from that of controller
    # it's the return value of the init function
    user_id = get_session(conn, :user_id)

    # condition statement, kinda like switch in C and C++
    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user)

      # default
      true ->
        assign(conn, :user, nil)
    end
  end
end
