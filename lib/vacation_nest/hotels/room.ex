defmodule VacationNest.Hotels.Room do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "rooms" do
    field :room_number, :integer
    field :status, Ecto.Enum, values: [:available, :unavailable], default: :available

    belongs_to :room_type, VacationNest.Hotels.RoomType

    many_to_many :bookings, VacationNest.Hotels.Booking,
      join_through: VacationNest.Hotels.BookingsRooms

    timestamps()
  end

  @attrs [:price, :room_number, :status]

  def changeset(room, attrs) do
    room
    |> cast(attrs, @attrs)
  end
end
