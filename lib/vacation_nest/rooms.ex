defmodule VacationNest.Rooms do
  import Ecto.Query
  alias VacationNest.Repo
  alias VacationNest.Hotels.{Room, RoomType, Booking, BookingsRooms}

  @check_in_time ~T[14:00:00.00]
  # @check_out_time ~T[19:00:00]

  def list_available_rooms(%{"check_in_day" => check_in_day, "check_out_day" => check_out_day}) do
    now = Timex.now("Asia/Kathmandu") |> DateTime.to_time()
    today = Date.utc_today()

    if (Date.from_iso8601!(check_in_day) == today && Timex.compare(now, @check_in_time) == -1) or
         Date.from_iso8601!(check_in_day) > today do
      available_rooms =
        Room
        |> join(:left, [r], b in assoc(r, :bookings))
        |> where(
          [r, b],
          is_nil(b.id) or b.check_in_day > ^check_out_day or
            (b.check_out_day < ^check_in_day and
               r.status == :available)
        )
        |> distinct([r, b], r)
        |> Repo.all()

      overlapping_available_rooms =
        Room
        |> join(:left, [r], b in assoc(r, :bookings))
        |> where(
          [r, b],
          (b.check_in_day >= ^check_in_day or b.check_out_day <= ^check_out_day or
             (b.check_in_day <= ^check_in_day and b.check_out_day >= ^check_out_day)) and
            b.status not in [:confirmed, :on_going]
        )
        |> distinct([r, b], r)
        |> Repo.all()

      available_rooms =
        (available_rooms ++ overlapping_available_rooms)
        |> MapSet.new()

      unavailable_rooms =
        Room
        |> join(:left, [r], b in assoc(r, :bookings))
        |> where(
          [r, b],
          (((b.check_in_day >= ^check_in_day and b.check_out_day >= ^check_out_day and
               b.check_in_day <= ^check_out_day) or
              (b.check_out_day <= ^check_out_day and b.check_in_day <= ^check_in_day and
                 b.check_in_day >= ^check_in_day) or
              (b.check_in_day <= ^check_in_day and b.check_out_day >= ^check_out_day)) and
             b.status in [:confirmed, :on_going]) or r.status == :unavailable
        )
        |> distinct([r, b], r)
        |> select([r, b], r.id)
        |> Repo.all()

      Enum.filter(available_rooms, &(&1.id not in unavailable_rooms))
      |> Repo.preload(:room_type)
    else
      []
    end
  end

  def get_price_for_room_type(type) do
    RoomType
    |> where([rt], rt.type == ^type)
    |> select([rt], rt.price)
    |> Repo.one()
  end

  def list_room_types do
    Repo.all(RoomType)
  end

  def list_room_types(params) do
    params =
      params
      |> Map.put("page_size", 9)

    case Flop.validate_and_run(RoomType, params, for: RoomType) do
      {:ok, {room_types, meta}} ->
        %{room_types: room_types, meta: meta}

      {:error, meta} ->
        %{room_types: [], meta: meta}
    end
  end

  def get_available_room_count_for_room_type(params, type) do
    case list_available_rooms(params) do
      [] ->
        0

      rooms ->
        rooms =
          rooms
          |> Enum.group_by(& &1.room_type.type)
          |> Enum.filter(fn {key, _} -> key == type.type end)

        {_, count} =
          if rooms == [] do
            {[], 0}
          else
            Enum.map(rooms, fn {type, rooms} -> {type, Enum.count(rooms)} end) |> Enum.at(0)
          end

        count
    end
  end

  def list_available_room_types_with_room_count(params) do
    case list_available_rooms(params) do
      [] ->
        %{}

      rooms ->
        rooms
        |> Enum.group_by(& &1.room_type)
        |> Enum.map(fn {type, rooms} -> {type, Enum.count(rooms)} end)
        |> Enum.into(%{})
    end
  end

  def get_room_count_for(params, type) do
    list_available_room_types_with_room_count(params)
    |> Map.filter(fn {key, _} ->
      key.type == type
    end)
    |> Map.values()
    |> Enum.at(0) || 0
  end

  def check_room_availability_for_booking?(
        %Booking{check_in_day: check_in_day, check_out_day: check_out_day} = booking
      ) do
    case list_available_rooms(%{
           "check_in_day" => Date.to_string(check_in_day),
           "check_out_day" => Date.to_string(check_out_day)
         }) do
      [] ->
        false

      available_rooms ->
        available_rooms = available_rooms |> Enum.map(& &1.id)

        rooms =
          booking.rooms
          |> Enum.map(& &1.id)

        rooms == Enum.filter(rooms, &(&1 in available_rooms))
    end
  end

  def check_room_availability?(params) do
    if list_available_rooms(params) == [], do: false, else: true
  end

  def create_booking_for_room(params) do
    room_count = params["room_count"] |> String.to_integer()

    case create_booking(%{
           total_amount: params["total_price"],
           check_in_day: params["check_in_day"],
           check_out_day: params["check_out_day"],
           user_id: params["user_id"]
         }) do
      {:ok, booking} ->
        list_available_rooms(params)
        |> Enum.filter(fn room -> room.room_type.type == params["room_type"] end)
        |> Enum.slice(0..(room_count - 1))
        |> Enum.each(&create_bookings_rooms(%{"booking_id" => booking.id, "room_id" => &1.id}))

        {:ok, booking}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_booking(attrs) do
    %Booking{} |> Booking.changeset(attrs) |> Repo.insert()
  end

  def create_bookings_rooms(attrs) do
    %BookingsRooms{}
    |> BookingsRooms.changeset(attrs)
    |> Repo.insert()
  end

  def list_bookings(user_id) do
    Repo.all(from b in Booking, where: b.user_id == ^user_id, order_by: [desc: b.updated_at])
    |> Repo.preload(rooms: [:room_type])
  end

  def list_bookings() do
    Repo.all(from b in Booking, order_by: [desc: b.updated_at])
    |> Repo.preload([:user, rooms: [:room_type]])
  end

  def update_booking(booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end

  def get_booking!(id) do
    Repo.get!(Booking, id)
  end

  def list_on_going_bookings_between_dates(user, check_in_day, check_out_day) do
    Booking
    |> where([b], b.user_id == ^user.id)
    |> where(
      [b],
      b.status in [:requested, :confirmed, :on_going] and
        ((b.check_out_day >= ^check_in_day and b.check_in_day <= ^check_in_day) or
           (b.check_out_day >= ^check_in_day and b.check_out_day <= ^check_out_day) or
           (b.check_in_day >= ^check_in_day and b.check_out_day <= ^check_out_day))
    )
    |> Repo.all()
  end

  def get_room!(id) do
    Repo.get!(Room, id) |> Repo.preload([:room_type, :bookings])
  end

  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  def list_rooms(params) do
    params =
      params
      |> Map.put("page_size", 9)

    case Flop.validate_and_run(Room, params, for: Room) do
      {:ok, {rooms, meta}} ->
        %{rooms: rooms |> Repo.preload(:room_type), meta: meta}

      {:error, meta} ->
        %{rooms: [], meta: meta}
    end
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def create_room(attrs) do
    case %Room{} |> Room.changeset(attrs) |> Repo.insert() do
      {:ok, room} ->
        {:ok, Repo.preload(room, :room_type)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def get_room_type!(id) do
    Repo.get!(RoomType, id)
  end

  def get_room_type_by_type(type) do
    RoomType
    |> where([rt], rt.type == ^type)
    |> Repo.one()
  end

  def create_room_type(attrs) do
    %RoomType{} |> RoomType.changeset(attrs) |> Repo.insert()
  end

  def update_room_type(%RoomType{} = room_type, attrs) do
    room_type
    |> RoomType.changeset(attrs)
    |> Repo.update()
  end

  def delete_room_type(%RoomType{} = room_type) do
    Repo.delete(room_type)
  end

  def change_room_type(%RoomType{} = room_type, attrs \\ %{}) do
    RoomType.changeset(room_type, attrs)
  end
end
