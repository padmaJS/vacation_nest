defmodule VacationNest.Hotels.Room do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "rooms" do
    field :price, :float
    field :room_number, :integer
    field :room_type, Ecto.Enum, values: [:single, :double], default: :single
    field :status, Ecto.Enum, values: [:available, :unavailable], default: :available

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
