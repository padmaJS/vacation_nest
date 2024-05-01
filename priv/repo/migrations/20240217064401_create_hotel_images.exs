defmodule VacationNest.Repo.Migrations.CreateHotelImages do
  use Ecto.Migration

  def change do
    create table(:hotel_images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :string

      timestamps()
    end
  end
end
