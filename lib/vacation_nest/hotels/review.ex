defmodule VacationNest.Hotels.Review do
  use VacationNest.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :comment, :string

    belongs_to :user, VacationNest.Accounts.User

    timestamps()
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:user_id, :rating, :comment])
    |> validate_required([:user_id, :rating])
    |> validate_inclusion(:rating, 1..5)
    |> validate_length(:comment, min: 10, max: 500)
    |> unique_constraint([:user_id])
  end
end
