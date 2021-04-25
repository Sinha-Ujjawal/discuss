defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Topic
  alias Discuss.Repo
  import Ecto.Query

  def index(conn, _params) do
    topics =
      from(topic in Topic)
      |> order_by([topic], asc: topic.id)
      |> Repo.all()

    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic}) do
    changeset = Topic.changeset(%Topic{}, topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid Input!")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render(conn, "edit.html", changeset: changeset, topic: topic)
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    topic_old = Topic |> Repo.get(topic_id)
    changeset = topic_old |> Topic.changeset(topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid Input!")
        |> render("edit.html", changeset: changeset, topic: topic_old)
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    # being very explicit about errors
    # will raise error and the process will exit!
    Topic |> Repo.get!(topic_id) |> Repo.delete!()

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: Routes.topic_path(conn, :index))
  end
end
