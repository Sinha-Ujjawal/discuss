defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Topic
  alias Discuss.Repo
  import Ecto.Query

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    topics =
      from(topic in Topic)
      |> order_by([topic], asc: topic.id)
      |> Repo.all()

    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render(conn, "topic.html", changeset: changeset, new: true)
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
        |> render("topic.html", changeset: changeset, new: true)
    end
  end

  def show(conn, %{"id" => topic_id}) do
    if topic = Repo.get(Topic, topic_id) do
      changeset = Topic.changeset(topic)
      render(conn, "topic.html", changeset: changeset, topic: topic)
    else
      conn
      |> put_flash(:error, "Topic does not exist!")
      |> redirect(to: Routes.topic_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    if topic = Repo.get(Topic, topic_id) do
      changeset = Topic.changeset(topic)
      render(conn, "topic.html", changeset: changeset, topic: topic)
    else
      conn
      |> put_flash(:error, "Topic does not exist!")
      |> redirect(to: Routes.topic_path(conn, :index))
    end
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    if topic_old = Topic |> Repo.get(topic_id) do
      changeset = topic_old |> Topic.changeset(topic)

      case Repo.update(changeset) do
        {:ok, _topic} ->
          conn
          |> put_flash(:info, "Topic Updated")
          |> redirect(to: Routes.topic_path(conn, :index))

        {:error, changeset} ->
          conn
          |> put_flash(:error, "Invalid Input!")
          |> render("topic.html", changeset: changeset, topic: topic_old)
      end
    else
      conn
      |> put_flash(:error, "Topic does not exist!")
      |> redirect(to: Routes.topic_path(conn, :index))
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
