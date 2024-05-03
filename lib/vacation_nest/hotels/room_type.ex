defmodule VacationNest.Hotels.RoomType do
  use VacationNest.Schema

  import Ecto.Changeset

  schema "room_types" do
    field :type, Ecto.Enum, values: [:single, :double, :triple]
    field :price, :float

    has_many :rooms, VacationNest.Hotels.Room

    timestamps()
  end

  def changeset(room_type, attrs) do
    room_type
    |> cast(attrs, [:type, :price])
    |> validate_required([:type, :price])
  end
end
