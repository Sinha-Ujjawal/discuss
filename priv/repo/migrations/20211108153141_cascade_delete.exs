defmodule Discuss.Repo.Migrations.CascadeDelete do
  use Ecto.Migration

  def change do
    drop_if_exists(constraint(:topics, "topics_user_id_fkey"))

    alter table(:topics) do
      modify(:user_id, references(:users, on_delete: :delete_all), null: false)
    end

    drop_if_exists(constraint(:comments, "comments_topic_id_fkey"))
    drop_if_exists(constraint(:comments, "comments_user_id_fkey"))

    alter table(:comments) do
      modify(:topic_id, references(:topics, on_delete: :delete_all), null: false)
      modify(:user_id, references(:users, on_delete: :delete_all), null: true)
    end
  end
end
