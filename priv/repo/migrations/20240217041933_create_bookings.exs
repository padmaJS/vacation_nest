defmodule VacationNest.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_amount, :integer
      add :check_in_day, :date
      add :check_out_day, :date
      add :status, :string
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :hotel_id, references(:hotels, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:bookings, [:user_id])
  end
end
