defmodule VacationNest.Hotels.Hotel do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  alias VacationNest.Repo

  schema "hotels" do
    field :name, :string
    field :rating, :float, default: 0.0
    field :ratings_count, :integer, default: 0
    field :total_rating, :integer, default: 0
    field :location, :string
    field :description, :string
    field :verified, :boolean, default: false
    field :amenities, {:array, :string}, default: []
    field :website, :string
    field :check_in_time, :time
    field :check_out_time, :time

    field :number_of_rooms, :integer, virtual: true
    field :price, :float, virtual: true

    belongs_to :user, VacationNest.Accounts.User

    has_many :rooms, VacationNest.Hotels.Room, on_delete: :delete_all
    has_many :images, VacationNest.Hotels.Image
    has_many :reviews, VacationNest.Hotels.Review

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
  @attrs [:ratings_count, :rating, :amenities, :user_id, :total_rating] ++ @req_attrs

  def changeset(hotel, attrs) do
    hotel
    |> cast(attrs, @attrs)
    |> validate_required(@req_attrs)
    |> maybe_put_number_of_rooms_and_price()
  end

  defp maybe_put_number_of_rooms_and_price(changeset) do
    rooms = get_field(changeset, :rooms)

    if rooms != [] do
      changeset =
        put_change(
          changeset,
          :number_of_rooms,
          Enum.count(rooms)
        )

      price =
        rooms
        |> Enum.at(0)
        |> Map.get(:price)

      put_change(changeset, :price, price)
    else
      changeset
    end
  end

  def update_rating_changeset(hotel, attrs) do
    hotel
    |> cast(attrs, [:rating, :ratings_count, :total_rating])
  end
end
