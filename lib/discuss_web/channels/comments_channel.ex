defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel

  alias Discuss.{Repo, Topic, Comment}
  import Ecto

  def join("comments:" <> topic_id, _payload, socket) do
    topic_id = String.to_integer(topic_id)

    if topic =
         Topic
         |> Repo.get(topic_id)
         |> Repo.preload(:comments) do
      {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    else
      {:error, %{reason: "Topic does not exist!"}, socket}
    end
  end

  def handle_in("comment:add", %{"content" => comment_text}, socket = %{assigns: %{topic: topic}}) do
    changeset =
      topic |> build_assoc(:comments) |> Comment.changeset(%{comment_text: comment_text})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}

      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
