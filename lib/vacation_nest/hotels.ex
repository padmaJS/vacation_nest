defmodule VacationNest.Hotels do
  import Ecto.Query, warn: false
  alias VacationNest.Repo

  alias VacationNest.Hotels.{Review, Hotel}

  def create_review(attrs) do
    %Review{hotel_id: get_hotel().id}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def update_review(review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  def get_review!(id), do: Repo.get!(Review, id)

  def get_review_by_user(user_id) do
    Review
    |> where([r], r.user_id == ^user_id)
    |> Repo.one()
  end

  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  def list_reviews() do
    Review
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get_rating() do
    query =
      Review
      |> select([r], avg(r.rating))

    Repo.one(query)
    |> case do
      nil ->
        0.0

      val ->
        val |> Decimal.to_float() || 0.0
    end
  end

  def get_rating_count() do
    Review
    |> select([r], count(r.id))
    |> Repo.one()
  end

  def get_hotel() do
    Repo.all(VacationNest.Hotels.Hotel) |> Enum.at(0)
  end

  def update_hotel(attrs) do
    get_hotel()
    |> Hotel.changeset(attrs)
    |> Repo.update()
  end

  def change_hotel(attrs \\ %{}) do
    get_hotel()
    |> Hotel.changeset(attrs)
  end
end
