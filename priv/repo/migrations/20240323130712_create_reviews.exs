defmodule VacationNest.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :integer
      add :comment, :text

      add :user_id, references(:users, type: :uuid)
      add :hotel_id, references(:hotels, type: :uuid)

      timestamps()
    end

    create unique_index(:reviews, [:user_id, :hotel_id])
  end
end
