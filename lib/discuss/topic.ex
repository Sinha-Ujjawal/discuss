defmodule Discuss.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  # 1. define model schema to "model" the table present in the database
  # 2. changeset for data validation checks

  schema "topics" do
    field :title, :string
    timestamps()
    belongs_to :user, Discuss.User
    # # equivalent to
    # model topics:
    #   title: string
    #   inserted_at: datetime
    #   updated_at: datetime
    #   user_id: bigint
    # #
  end

  def changeset(struct, params \\ %{}) do
    # struct- A dictionary (hashmap) that contains some data.
    #         Represents a record (or a record we want to save) in the database
    # ------------------------------------------------------------------------------------
    # params- A dictionary (hashmap) that contains the properties we want to
    #         update the struct (data) with
    # ------------------------------------------------------------------------------------
    # cast- produces a changeset
    # ------------------------------------------------------------------------------------
    # validators- adds errors to the changeset (if any)
    # ------------------------------------------------------------------------------------
    # at the end, we get an updated changeset

    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end
