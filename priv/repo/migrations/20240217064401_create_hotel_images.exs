defmodule VacationNest.Repo.Migrations.CreateHotelImages do
  use Ecto.Migration

  def change do
    create table(:hotel_images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :hotel_id, references(:hotels, type: :uuid)
      add :image, :string

      timestamps()
    end

    create index(:hotel_images, [:hotel_id])
  end
end
