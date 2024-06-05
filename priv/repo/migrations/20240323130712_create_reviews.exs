defmodule VacationNest.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :integer
      add :comment, :text

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :hotel_id, references(:hotels, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:reviews, [:user_id])
  end
end
