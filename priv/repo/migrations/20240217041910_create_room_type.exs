defmodule VacationNest.Repo.Migrations.CreateRoomType do
  use Ecto.Migration

  def change do
    create table(:room_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :price, :float

      timestamps()
    end

    create unique_index(:room_types, [:type])
  end
end
