defmodule VacationNest.Hotels.Room do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:room_number, :status], sortable: [:room_number, :status]
  }

  schema "rooms" do
    field :room_number, :integer
    field :status, Ecto.Enum, values: [:available, :unavailable], default: :available

    belongs_to :room_type, VacationNest.Hotels.RoomType

    many_to_many :bookings, VacationNest.Hotels.Booking,
      join_through: VacationNest.Hotels.BookingsRooms

    timestamps()
  end

  @attrs [:room_number, :status, :room_type_id]

  def changeset(room, attrs) do
    room
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> unique_constraint(:room_number)
  end
end
