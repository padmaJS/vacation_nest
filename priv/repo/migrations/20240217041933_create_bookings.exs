defmodule VacationNest.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid)
      add :total_amount, :integer
      add :check_in_day, :date
      add :check_out_day, :date
      add :status, :string

      timestamps()
    end

    create index(:bookings, [:user_id])
  end
end
