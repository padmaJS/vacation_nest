defmodule VacationNest.Hotels do
  import Ecto.Query, warn: false
  alias VacationNest.Repo

  alias VacationNest.Hotels.{Hotel, Room}

  def list_hotels do
    Repo.all(Hotel)
  end

  def list_hotels(attrs) do
    now = Timex.now("Asia/Kathmandu") |> DateTime.to_time()
    today = Date.utc_today()

    query =
      Hotel
      # |> where([h], h.verified == true)
      |> where([h], h.location == ^attrs["location"])

    query =
      if Date.from_iso8601!(attrs["check_in_day"]) == today do
        where(query, [h], h.check_in_time > ^now)
      else
        query
      end

    # |> order_by([h], desc: h.rating)
    query
    |> join(:inner, [h], r in assoc(h, :rooms))
    |> group_by([h, r], h.id)
    |> having([h, r], count(r.id) >= ^attrs["number_of_rooms"])
    |> Repo.all()
    |> Repo.preload(:rooms)
  end

  def get_hotel!(id), do: Repo.get!(Hotel, id)

  def create_hotel(attrs \\ %{}) do
    Repo.transaction(fn ->
      case %Hotel{}
           |> Hotel.changeset(attrs)
           |> Repo.insert() do
        {:ok, hotel} ->
          create_rooms_for_hotel(hotel, attrs)

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
    Hotel.changeset(hotel, attrs)
  end

  def get_rooms_for_hotel(hotel) do
    Repo.all(from r in Room, where: r.hotel_id == ^hotel.id)
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
end
