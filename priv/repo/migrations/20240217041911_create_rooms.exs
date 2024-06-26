defmodule VacationNest.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_number, :integer
      add :status, :string
      add :room_type_id, references(:room_types, type: :uuid, on_delete: :delete_all)
      add :hotel_id, references(:hotels, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:rooms, [:room_number])
  end
end
