defmodule VacationNest.Hotels.RoomType do
  use VacationNest.Schema

  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:type], sortable: [:type]
  }

  schema "room_types" do
    field :type, :string
    field :price, Money.Ecto.Amount.Type
    field :image, :string
    field :description, :string

    has_many :rooms, VacationNest.Hotels.Room, on_delete: :delete_all

    timestamps()
  end

  def changeset(room_type, attrs) do
    room_type
    |> cast(attrs, [:type, :image, :description])
    |> validate_required([:type, :description])
    |> maybe_put_price(attrs)
    |> maybe_validate_type()
  end

  defp maybe_put_price(changeset, attrs) do
    case attrs["price"] do
      nil ->
        changeset

      price ->
        case price |> Money.parse() do
          {:ok, money} ->
            changeset |> put_change(:price, money)

          _ ->
            changeset
            |> add_error(:price, "Invalid price")
        end
    end
  end

  defp maybe_validate_type(changeset) do
    case get_field(changeset, :type) do
      nil ->
        changeset

      _type ->
        validate_format(changeset, :type, ~r/^\w+\s?\w*$/, message: "must contain letters only")
    end
  end
end
