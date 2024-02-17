defmodule VacationNest.Hotels.Hotel do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "hotels" do
    field :name, :string
    field :rating, :float, default: 0.0
    field :ratings_count, :integer, default: 0
    field :location, :string
    field :description, :string
    field :verified, :boolean, default: false
    field :amenities, {:array, :string}, default: []
    field :website, :string
    field :check_in_time, :time
    field :check_out_time, :time

    belongs_to :manager, VacationNest.Accounts.User

    has_many :rooms, VacationNest.Hotels.Room
    has_many :images, VacationNest.Hotels.Image

    timestamps()
  end

  @req_attrs [
    :name,
    :location,
    :description,
    :verified,
    :website,
    :check_in_time,
    :check_out_time
  ]
  @attrs [:ratings_count, :rating, :amenities, :manager_id] ++ @req_attrs

  def changeset(hotel, attrs) do
    hotel
    |> cast(attrs, @attrs)
    |> validate_required(@req_attrs)
  end
end
