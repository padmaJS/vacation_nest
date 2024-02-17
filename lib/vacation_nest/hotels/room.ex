defmodule VacationNest.Hotels.Room do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :description, :string
    field :price, :float
    # field :images, VacationNest.FileImage.Uploader.Type
    belongs_to :hotel, VacationNest.Hotels.Hotel

    timestamps()
  end

  @attrs []

  def changeset(room, attrs) do
    room
    |> cast(attrs, @attrs)
    |> validate_required([])
    |> cast_attachments(attrs, [:image])
  end
end
