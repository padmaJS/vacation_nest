defmodule VacationNest.Hotels.RoomType do
  use VacationNest.Schema

  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:type], sortable: [:type]
  }

  schema "room_types" do
    field :type, Ecto.Enum, values: [:single, :double, :triple]
    field :price, Money.Ecto.Amount.Type
    field :image, :string
    field :description, :string

    has_many :rooms, VacationNest.Hotels.Room

    timestamps()
  end

  def changeset(room_type, attrs) do
    room_type
    |> cast(attrs, [:type, :price, :image, :description])
    |> validate_required([:type, :price, :image, :description])
  end
end
