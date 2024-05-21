defmodule VacationNest.Hotels.Hotel do
  use VacationNest.Schema

  import Ecto.Changeset

  schema "hotels" do
    field :name, :string
    field :address, :string
    field :checkin_time, :time
    field :checkout_time, :time
    field :room_images, {:array, :string}
    field :amenities_images, {:array, :string}
    field :email, :string
    field :instagram_url, :string
    field :facebook_url, :string

    timestamps()
  end

  def changeset(hotel, attrs) do
    hotel
    |> cast(attrs, [:name, :checkin_time, :checkout_time, :room_images, :amenities_images])
  end
end
