defmodule VacationNest.Hotels.Room do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "rooms" do
    field :price, :float
    field :room_number, :integer
    field :status, Ecto.Enum, values: [:available, :unavailable], default: :available
    belongs_to :hotel, VacationNest.Hotels.Hotel

    timestamps()
  end

  @attrs [:price, :room_number, :status, :hotel_id]

  def changeset(room, attrs) do
    room
    |> cast(attrs, @attrs)
  end
end
