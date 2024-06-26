defmodule VacationNest.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :phone_number, :string, null: false
      add :profile_image, :string
      add :name, :string
      add :gender, :string
      add :hashed_password, :string, null: false
      add :role, :string
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:phone_number])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
