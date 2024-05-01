defmodule VacationNest.Hotels.Image do
  use VacationNest.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "hotel_images" do
    field :image, VacationNest.FileImage.Type

    timestamps()
  end

  def changeset(hotel_image, attrs) do
    hotel_image
    |> cast(attrs, [:hotel_id])
    |> validate_required([:hotel_id])
  end

  def image_changeset(hotel_image, attrs) do
    hotel_image
    |> cast_attachments(attrs, [:image])
    |> validate_required([:image])
  end
end
