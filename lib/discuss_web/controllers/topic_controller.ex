defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Topic
  alias Discuss.Repo
  import Ecto
  import Ecto.Query

  plug(DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete])
  plug(:ensure_topic when action in [:edit, :update, :delete])
  plug(:ensure_topic_owner when action in [:edit, :update, :delete])

  def index(conn, _params) do
    topics =
      from(topic in Topic)
      |> order_by([topic], asc: topic.id)
      |> Repo.all()

    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render(conn, "topic_form.html", changeset: changeset, new: true)
  end

  def create(conn = %{assigns: %{user: user}}, _params = %{"topic" => topic}) do
    case user
         |> build_assoc(:topics)
         |> Topic.changeset(topic)
         |> Repo.insert() do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid Input!")
        |> render("topic_form.html", changeset: changeset, new: true)
    end
  end

  def edit(conn = %{assigns: %{topic: topic}}, _params) do
    changeset = Topic.changeset(topic)
    render(conn, "topic_form.html", changeset: changeset, topic: topic)
  end

  def update(conn = %{assigns: %{topic: topic_old}}, _params = %{"topic" => topic}) do
    changeset = topic_old |> Topic.changeset(topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid Input!")
        |> render("topic_form.html", changeset: changeset, topic: topic_old)
    end
  end

  def delete(conn = %{assigns: %{topic: topic}}, _params) do
    # being very explicit about errors
    # will raise error and the process will exit!
    topic |> Repo.delete!()

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  # plugs
  def ensure_topic(conn = %{params: %{"id" => topic_id}}, _params) do
    if topic = Repo.get(Topic, topic_id) do
      assign(conn, :topic, topic)
    else
      conn
      |> put_flash(:error, "Topic does not exist!")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt
    end
  end

  def ensure_topic_owner(conn = %{assigns: %{user: user, topic: topic}}, _params) do
    if user.id == topic.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You don't have permission for this topic!")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt
    end
  end
end
