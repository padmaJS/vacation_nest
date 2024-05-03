defmodule VacationNest.Hotels do
  import Ecto.Query, warn: false
  alias VacationNest.Repo

  alias VacationNest.Hotels.Review

  def create_review(attrs) do
    %Review{}
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
  end

  def get_rating() do
    reviews = list_reviews()
    ratings_count = Enum.count(reviews)

    if ratings_count > 0,
      do: Enum.reduce(reviews, 0, fn review, acc -> review.rating + acc end) / ratings_count,
      else: 0.0
  end

  def get_rating_count() do
    Review
    |> select([r], count(r.id))
    |> Repo.one()
  end
end
