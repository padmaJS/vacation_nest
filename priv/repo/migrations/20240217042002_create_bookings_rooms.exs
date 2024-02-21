defmodule VacationNest.Repo.Migrations.CreateBookingsRooms do
  use Ecto.Migration

  def change do
    create table(:bookings_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :booking_id, references(:bookings, type: :uuid)
      add :room_id, references(:rooms, type: :uuid)
    end

    create unique_index(:bookings_rooms, [:booking_id, :room_id])
  end
end
