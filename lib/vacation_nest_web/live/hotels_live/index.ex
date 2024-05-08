defmodule VacationNestWeb.HotelsLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid mx-auto w-1/2 !gap-y-10 bg-gray-50 p-8 my-5 shadow-2xl rounded-lg">
      <%= if @rooms_available? do %>
        <.table id="rooms" rows={@rooms}>
          <:col :let={{room_type, _count, _price}} label="Room Type"><%= room_type %></:col>
          <:col :let={{_room_type, count, _price}} label="Room Count"><%= count %></:col>
          <:col :let={{_room_type, _count, price}} label="Room Price"><%= price %></:col>
        </.table>
        <div class="mx-auto">
          <.link
            navigate={~p"/hotel/book?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}"}
            class="text-white  text-xl bg-[#2EAFA0] hover:bg-[#2A9D8F]  transition duration-300 focus:ring-4 focus:ring-emerald-300 font-semibold rounded-lg px-7 py-3 focus:outline-none transition duration-300"
          >
            Book room?
          </.link>
        </div>
      <% else %>
        Oops. Seems we have no room available for now.
      <% end %>
    </div>

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
     |> assign(:check_out_day, check_out_day)
     |> assign(:current_page, :book)}
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
