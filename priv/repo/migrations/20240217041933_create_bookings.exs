defmodule VacationNest.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid)
      add :hotel_id, references(:hotels, type: :uuid)
      add :total_amount, :float
      add :check_in, :naive_datetime
      add :check_out, :naive_datetime
      add :status, :string

      timestamps()
    end

    create index(:bookings, [:user_id])
    create index(:bookings, [:hotel_id])
    create unique_index(:bookings, [:user_id, :hotel_id])
  end
end
