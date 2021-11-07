defmodule Discuss.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  import Jason

  @derive {Jason.Encoder, only: [:comment_text, :user]}

  schema "comments" do
    field(:comment_text, :string)

    belongs_to(:topic, Discuss.Topic)
    belongs_to(:user, Discuss.User)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:comment_text])
    |> validate_required([:comment_text])
  end
end
