defmodule VacationNest.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :hotel_id, references(:hotels, type: :uuid)
      add :room_number, :integer
      add :price, :float
      add :status, :string
      add :images, {:array, :string}

      timestamps()
    end

    create index(:rooms, [:hotel_id])
    create unique_index(:rooms, [:hotel_id, :room_number])
  end
end
