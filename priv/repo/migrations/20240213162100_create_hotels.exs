defmodule VacationNest.Repo.Migrations.CreateHotelsRooms do
  use Ecto.Migration

  def change do
    create table(:hotels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :manager_id, references(:users, type: :uuid)
      add :rating, :float
      add :ratings_count, :integer
      add :location, :string
      add :description, :text
      add :verified, :boolean, default: false
      add :amenities, {:array, :string}
      add :website, :string
      add :check_in_time, :time
      add :check_out_time, :time
      add :images, {:array, :string}

      timestamps()
    end

    create index(:hotels, [:manager_id])
    create unique_index(:hotels, [:name])
  end
end
