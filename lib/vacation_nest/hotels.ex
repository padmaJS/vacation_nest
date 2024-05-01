defmodule VacationNest.Hotels do
  import Ecto.Query, warn: false
  alias VacationNest.Repo

  alias VacationNest.Hotels.{Hotel, Room, Booking, BookingsRooms, Review}

  def list_hotels do
    Repo.all(Hotel)
  end

  def list_hotels(attrs) do
    now = Timex.now("Asia/Kathmandu") |> DateTime.to_time()
    today = Date.utc_today()

    query =
      Room
      |> join(:inner, [r], h in assoc(r, :hotel))
      # |> where([r, h], h.verified == true)
      |> where([r, h], h.location == ^attrs["location"])
      |> join(:left, [r, h], b in assoc(r, :bookings))
      |> where(
        [r, h, b],
        is_nil(b.id) or b.check_in_day > ^attrs["check_in_day"] or
          b.check_out_day < ^attrs["check_out_day"]
      )

    query =
      if Date.from_iso8601!(attrs["check_in_day"]) == today do
        where(query, [r, h], h.check_in_time > ^now)
      else
        query
      end

    query
    |> group_by([r, h, b], h.id)
    |> having([r, h, b], count(r.id) >= ^attrs["number_of_rooms"])
    |> select([r, h, b], h)
    |> Repo.all()
    |> Repo.preload(:rooms)
  end

  def get_hotel!(id), do: Repo.get!(Hotel, id) |> Repo.preload(reviews: [:user])

  def create_hotel(attrs \\ %{}) do
    Repo.transaction(fn ->
      case %Hotel{}
           |> Hotel.changeset(attrs)
           |> Repo.insert() do
        {:ok, hotel} ->
          create_rooms_for_hotel(hotel |> Repo.preload(:rooms), attrs)

        _ ->
          Repo.rollback("Error creating hotel")
      end
    end)
  end

  def update_hotel(%Hotel{} = hotel, attrs) do
    Repo.transaction(fn ->
      case hotel
           |> Hotel.changeset(attrs)
           |> Repo.update() do
        {:ok, hotel} ->
          update_rooms_for_hotel(hotel, attrs)

        _ ->
          Repo.rollback("Error updating hotel")
      end
    end)
  end

  def delete_hotel(%Hotel{} = hotel) do
    Repo.delete(hotel)
  end

  def change_hotel(hotel \\ %Hotel{}, attrs \\ %{}) do
    hotel
    |> Repo.preload(:rooms)
    |> Hotel.changeset(attrs)
  end

  def get_rooms_for_hotel(hotel) do
    Repo.all(from r in Room, where: r.hotel_id == ^hotel.id)
  end

  def get_available_rooms_for_hotel(hotel) do
    Repo.all(
      from r in Room,
        where: r.hotel_id == ^hotel.id and r.status == :available,
        order_by: r.room_number
    )
  end

  def create_rooms_for_hotel(hotel, %{"number_of_rooms" => room_count} = attrs) do
    available_rooms = count_available_rooms_for_hotel(hotel) + 1

    available_rooms..String.to_integer(room_count)
    |> Enum.each(fn _ ->
      total_rooms = count_total_rooms_for_hotel(hotel) || 0

      attrs
      |> Map.put("hotel_id", hotel.id)
      |> Map.put("room_number", total_rooms + 1)
      |> create_room()
    end)

    hotel
  end

  def update_rooms_for_hotel(hotel, attrs) do
    number_of_rooms = String.to_integer(attrs["number_of_rooms"])
    available_rooms = count_available_rooms_for_hotel(hotel)

    cond do
      available_rooms < number_of_rooms ->
        create_rooms_for_hotel(hotel, attrs)

      available_rooms > number_of_rooms ->
        rooms = list_rooms_for_hotel(hotel)

        number_of_rooms..(available_rooms - 1)
        |> Enum.each(&(Enum.at(rooms, &1) |> delete_room))

      true ->
        nil
    end

    hotel
    |> get_rooms_for_hotel()
    |> Enum.each(fn room -> room |> Room.changeset(attrs) |> Repo.update() end)

    hotel
  end

  def create_room(attrs) do
    %Room{} |> Room.changeset(attrs) |> Repo.insert()
  end

  def delete_room(room), do: Repo.delete(room)

  def count_total_rooms_for_hotel(hotel) do
    Hotel
    |> where([h], h.id == ^hotel.id)
    |> join(:inner, [h], r in assoc(h, :rooms))
    |> group_by([h, r], h.id)
    |> select([h, r], count(r.id))
    |> Repo.one()
  end

  def list_rooms_for_hotel(hotel) do
    Repo.all(from r in Room, where: r.hotel_id == ^hotel.id, order_by: r.room_number)
  end

  def count_available_rooms_for_hotel(hotel) do
    Hotel
    |> where([h], h.id == ^hotel.id)
    |> join(:inner, [h], r in assoc(h, :rooms))
    |> where([h, r], r.status == :available)
    |> select([h, r], count(r.id))
    |> Repo.one()
  end

  def get_price_per_room(hotel) do
    Hotel
    |> where([h], h.id == ^hotel.id)
    |> join(:inner, [h], r in assoc(h, :rooms))
    |> limit(1)
    |> select([h, r], r.price)
    |> Repo.one()
  end

  def create_booking(attrs) do
    Repo.transaction(fn ->
      case %Booking{} |> Booking.changeset(attrs) |> Repo.insert() do
        {:ok, booking} ->
          attrs[:hotel_id]
          |> get_hotel!()
          |> get_available_rooms_for_hotel()
          |> Enum.slice(0..(String.to_integer(attrs[:number_of_rooms]) - 1))
          |> Enum.each(&create_bookings_rooms(%{"booking_id" => booking.id, "room_id" => &1.id}))

          booking

        _ ->
          Repo.rollback("Error creating booking")
      end
    end)
  end

  def create_bookings_rooms(attrs) do
    %BookingsRooms{}
    |> BookingsRooms.changeset(attrs)
    |> Repo.insert()
  end

  def create_review(attrs) do
    Repo.transaction(fn ->
      case %Review{}
           |> Review.changeset(attrs)
           |> Repo.insert() do
        {:ok, review} ->
          hotel = get_hotel!(review.hotel_id)
          total_rating = hotel.total_rating + review.rating
          ratings_count = hotel.ratings_count + 1

          Hotel.update_rating_changeset(
            hotel,
            %{
              rating: total_rating / ratings_count,
              ratings_count: ratings_count,
              total_rating: total_rating
            }
          )
          |> Repo.update()

          review

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_review(old_review, attrs) do
    Repo.transaction(fn ->
      case old_review
           |> Review.changeset(attrs)
           |> Repo.update() do
        {:ok, review} ->
          hotel = get_hotel!(review.hotel_id)
          total_rating = hotel.total_rating - old_review.rating + review.rating

          Hotel.update_rating_changeset(
            hotel,
            %{
              rating: total_rating / hotel.ratings_count,
              total_rating: total_rating
            }
          )
          |> Repo.update()

          review

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def get_review!(id), do: Repo.get!(Review, id)

  def get_review_by_user_and_hotel(user_id, hotel_id) do
    Review
    |> where([r], r.user_id == ^user_id and r.hotel_id == ^hotel_id)
    |> Repo.one()
  end

  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  def list_reviews_for_hotel(hotel_id) do
    Review
    |> where([r], r.hotel_id == ^hotel_id)
    |> Repo.all()
  end
end
