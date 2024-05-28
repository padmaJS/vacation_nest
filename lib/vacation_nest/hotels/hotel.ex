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
    field :phone_number, :string
    field :instagram_url, :string
    field :facebook_url, :string
    field :rating, :float
    field :ratings_count, :integer
    field :verified, :boolean, default: false
    has_many :rooms, VacationNest.Hotels.Room
    has_many :reviews, VacationNest.Hotels.Review
    timestamps()
  end

  def changeset(hotel, attrs) do
    hotel
    |> cast(attrs, [:name, :checkin_time, :checkout_time, :room_images, :amenities_images, :phone_number, :email, :address, :instagram_url, :facebook_url, :rating, :ratings_count, :verified])
    |> maybe_validate_phone_number(attrs)
  end

  defp maybe_validate_phone_number(changeset, _attrs) do
    changeset
    |> validate_format(:phone_number, ~r/^98[0-9]{8}$/, message: "must be a valid phone number")
    |> unique_constraint(:phone_number)
  end
end
