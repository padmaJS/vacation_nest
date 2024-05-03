defmodule VacationNestWeb.HotelsLive.Book do
  use VacationNestWeb, :live_component
  import VacationNest.DisplayHelper

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Book the room</.header>

      <.form for={@form} phx-target={@myself} phx-submit="book_room" phx-change="validate">
        <div class="mb-4">
          <label for="room_type" class="block text-sm font-medium text-gray-900">
            Select a room category
          </label>
          <.input
            type="select"
            field={@form[:room_type]}
            options={@room_types}
            prompt="Select Room Type"
          />
          <.input
            type="number"
            field={@form[:room_count]}
            value={@form[:room_count].value}
            max={@rooms |> Map.get(@form[:room_type].value, 0)}
            min={if @rooms |> Map.get(@form[:room_type].value, 0) > 0, do: 1, else: 0}
            step="1"
          />
          <div class="mb-4">
            <label for="total_price" class="block text-sm font-medium text-gray-900">
              Total Price
            </label>
            <.input
              type="hidden"
              field={@form[:total_price]}
              value={
                @form[:room_type].value &&
                  get_price_for_room(
                    @form[:room_count].value,
                    @form[:room_type].value,
                    @number_of_days
                  )
              }
            />
            <span id="total_price" class="block mt-1 font-semibold text-green-600">
              <%= if val = @form[:room_type].value,
                do:
                  get_price_for_room(
                    @form[:room_count].value,
                    val,
                    @number_of_days
                  ),
                else: 0 %>
            </span>
          </div>
        </div>
        <.button
          class="text-white inline-flex items-center bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-emerald-600 dark:hover:bg-emerald-700 dark:focus:ring-emerald-800"
          phx-disable-with="Booking..."
        >
          Book now
        </.button>
        <.link
          patch={@patch}
          class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
        >
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  @impl true
  def update(
        %{
          check_in_day: check_in_day,
          check_out_day: check_out_day
        } = assigns,
        socket
      ) do
    number_of_days =
      Date.from_iso8601!(check_out_day)
      |> Date.diff(Date.from_iso8601!(check_in_day))

    rooms =
      Rooms.list_room_types_with_room_count(%{
        "check_in_day" => check_in_day,
        "check_out_day" => check_out_day
      })

    room_types = rooms |> Map.keys()

    {:ok,
     assign(socket, assigns)
     |> assign(:rooms, rooms)
     |> assign(:room_types, room_types)
     |> assign(:number_of_days, number_of_days)
     |> assign_form(%{"total_price" => 0, "room_count" => 0})}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, socket |> assign_form(params)}
  end

  def handle_event("book_room", params, socket) do
    if Rooms.list_on_going_bookings_between_dates(
         socket.assigns.current_user,
         socket.assigns.check_in_day,
         socket.assigns.check_out_day
       ) == [] do
      params =
        Map.put(params, "check_in_day", socket.assigns.check_in_day)
        |> Map.put("check_out_day", socket.assigns.check_out_day)
        |> Map.put("user_id", socket.assigns.current_user.id)

      Rooms.create_booking_for_room(params)

      {:noreply,
       socket
       |> put_flash(:info, "Room book requested successfully.")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Check your booking requests first.")
       |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp assign_form(socket, changeset \\ %{}) do
    assign(socket, :form, to_form(changeset))
  end

  defp get_price_for_room(room_count, room_type, number_of_days) do
    cond do
      room_count == "" ->
        0.0

      is_binary(room_count) ->
        {room_count, _} = Integer.parse(room_count)
        room_count * Rooms.get_price_for_room_type(room_type) * number_of_days

      is_integer(room_count) ->
        room_count * Rooms.get_price_for_room_type(room_type) * number_of_days

      true ->
        0.0
    end
  end
end
