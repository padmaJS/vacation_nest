defmodule VacationNest.Hotels.BookingsRooms do
  use VacationNest.Schema

  import Ecto.Changeset

  schema "bookings_rooms" do
    belongs_to :booking, VacationNest.Hotels.Booking
    belongs_to :room, VacationNest.Hotels.Room

    timestamps()
  end

  def changeset(booking_room, attrs) do
    booking_room
    |> cast(attrs, [:booking_id, :room_id])
    |> validate_required([:booking_id, :room_id])
  end
end
