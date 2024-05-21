defmodule VacationNestWeb.HotelsLive.Book do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[60%] mx-auto bg-gray-50 p-14 pb-8 my-5 shadow-2xl rounded-lg grid grid-cols-2 gap-4">
      <div>
        <.header>Book <%= @room_type.type %></.header>

        <.simple_form for={@form} phx-submit="book_room" phx-change="validate">
          <div class="mb-4">
            <.input
              type="number"
              field={@form[:room_count]}
              value={@form[:room_count].value}
              max={@room_count}
              min={if @room_count > 0, do: 1, else: 0}
              step="1"
              label="Room count"
            />
            <div class="my-4 flex space-x-3">
              <label for="total_price" class="block text-xl font-semibold text-gray-900">
                Total Price:
              </label>
              <span id="total_price" class="block text-xl font-semibold text-green-600">
                <%= Money.to_string(
                  get_price_for_room(
                    @form[:room_count].value,
                    @room_type.type,
                    @number_of_days
                  )
                ) %>
              </span>
            </div>
          </div>
          <:actions>
            <.button
              class="text-white inline-flex items-center bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-emerald-600 dark:hover:bg-emerald-700 dark:focus:ring-emerald-800"
              phx-disable-with="Booking..."
            >
              Book now
            </.button>
            <.link
              patch={~p"/hotel/check?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}"}
              class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
            >
              Cancel
            </.link>
          </:actions>
        </.simple_form>
      </div>
      <img src={@room_type.image} class="h-[240px] w-[240px] mx-auto object-cover" />
    </div>
    """
  end

  @impl true
  def mount(
        %{
          "check_in_day" => check_in_day,
          "check_out_day" => check_out_day,
          "room_type" => room_type
        } = assigns,
        _,
        socket
      ) do
    number_of_days =
      Date.from_iso8601!(check_out_day)
      |> Date.diff(Date.from_iso8601!(check_in_day))

    room_count = Rooms.get_room_count_for(assigns, room_type)

    {:ok,
     socket
     |> assign(:room_count, room_count)
     |> assign(:number_of_days, number_of_days)
     |> assign(:check_in_day, check_in_day)
     |> assign(:check_out_day, check_out_day)
     |> assign(:room_type, Rooms.get_room_type_by_type(room_type))
     |> assign_form(%{"room_count" => 0})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _index, _params) do
    socket
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, socket |> assign_form(params)}
  end

  def handle_event(
        "book_room",
        %{"room_count" => room_count} = params,
        socket
      ) do
    on_going_bookings =
      Rooms.list_on_going_bookings_between_dates(
        socket.assigns.current_user,
        socket.assigns.check_in_day,
        socket.assigns.check_out_day
      )

    cond do
      on_going_bookings == [] &&
          Rooms.get_available_room_count_for_room_type(
            params
            |> Map.put("check_in_day", socket.assigns.check_in_day)
            |> Map.put("check_out_day", socket.assigns.check_out_day),
            socket.assigns.room_type
          ) >= String.to_integer(room_count) ->
        params =
          Map.put(params, "check_in_day", socket.assigns.check_in_day)
          |> Map.put("check_out_day", socket.assigns.check_out_day)
          |> Map.put("user_id", socket.assigns.current_user.id)
          |> Map.put(
            "total_price",
            get_price_for_room(
              room_count,
              socket.assigns.room_type.type,
              socket.assigns.number_of_days
            )
          )
          |> Map.put("room_type", socket.assigns.room_type.type)

        Rooms.create_booking_for_room(params)

        {:noreply,
         socket
         |> put_flash(:info, "Room book requested successfully.")
         |> push_navigate(to: ~p"/")}

      on_going_bookings != [] ->
        {:noreply,
         socket
         |> put_flash(:error, "Check your booking requests first.")}

      true ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong. Please try again.")}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp get_price_for_room(room_count, room_type, number_of_days) do
    cond do
      room_count == "" ->
        Money.new(0)

      is_binary(room_count) ->
        {room_count, _} = Integer.parse(room_count)
        Money.multiply(Rooms.get_price_for_room_type(room_type), room_count * number_of_days)

      is_integer(room_count) ->
        Money.multiply(Rooms.get_price_for_room_type(room_type), room_count * number_of_days)

      true ->
        Money.new(0)
    end
  end
end
