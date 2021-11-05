defmodule Discuss.Repo.Migrations.AddComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :comment_text, :string
      add :topic_id, references(:topics), null: false
      add :user_id, references(:users), null: true

      timestamps()
    end
  end
end
