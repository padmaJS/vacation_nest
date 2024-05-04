defmodule VacationNestWeb.HotelsLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @rooms_available? do %>
      <table class="table-auto w-full text-left text-gray-600">
        <thead>
          <tr class="border-b border-gray-200">
            <th class="py-4 px-6 text-xs font-medium uppercase tracking-wider">Room Type</th>
            <th class="py-4 px-6 text-xs font-medium uppercase tracking-wider">Available Rooms</th>
            <th class="py-4 px-6 text-xs font-medium uppercase tracking-wider">Price per Room</th>
          </tr>
        </thead>
        <tbody>
          <%= for {room_type, count, price} <- @rooms do %>
            <tr class="border-b border-gray-200 hover:bg-gray-100">
              <td class="py-4 px-6"><%= room_type %></td>
              <td class="py-4 px-6"><%= count %></td>
              <td class="py-4 px-6">
                <%= price %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
      <.link navigate={~p"/hotel/book?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}"}>
        Book room?
      </.link>
    <% else %>
      Oops. Seems we have no room available for now.
    <% end %>

    <.modal
      :if={@live_action == :book}
      id="book_room-modal"
      show
      on_cancel={
        JS.patch(~p"/hotel/check?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}")
      }
    >
      <.live_component
        module={VacationNestWeb.HotelsLive.Book}
        action={@live_action}
        id="book_room"
        check_in_day={@check_in_day}
        check_out_day={@check_out_day}
        patch={~p"/hotel/check?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}"}
        current_user={@current_user}
      />
    </.modal>
    """
  end

  @impl true
  def mount(
        %{"check_in_day" => check_in_day, "check_out_day" => check_out_day} = params,
        _session,
        socket
      ) do
    rooms =
      Rooms.list_room_types_with_room_count(params)
      |> Enum.map(fn {room_type, count} ->
        {room_type, count, Rooms.get_price_for_room_type(room_type)}
      end)
      |> Enum.sort_by(fn {_room_type, _count, price} -> price.amount end)

    rooms_available? = Rooms.check_room_availability?(params)

    {:ok,
     socket
     |> assign_form(params)
     |> assign(:rooms, rooms)
     |> assign(:rooms_available?, rooms_available?)
     |> assign(:check_in_day, check_in_day)
     |> assign(:check_out_day, check_out_day)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _index, _params) do
    socket
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: :hotel))
  end
end
