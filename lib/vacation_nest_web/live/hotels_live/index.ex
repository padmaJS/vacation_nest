defmodule VacationNestWeb.HotelsLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms
  import VacationNest.DisplayHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto w-3/4 my-4">
      <%= if @rooms_available? do %>
        <div class="flex flex-col space-y-6">
          <div
            :for={{room_type, count} <- @rooms}
            class="grid grid-cols-3 bg-gray-10 p-4 shadow-xl rounded-lg gap-4"
          >
            <img src={room_type.image} class="w-[250px] h-[250px] object-cover" />
            <div class="grid grid-rows-3">
              <div class="row-start-2">
                <p class="text-2xl font-semibold"><%= humanize_text(room_type.type) %></p>
                <p class="text-gray-500"><%= room_type.description %></p>
              </div>
              <p class="text-lg font-me  row-start-3">
                <%= count %> room<%= if count > 1, do: "s" %> available
              </p>
            </div>
            <div class="grid grid-rows-3">
              <span class=" row-start-2 !text-nowrap">
                <p class="text-2xl font-semibold"><%= room_type.price %></p>
                per night
              </span>
              <div class="row-start-3">
                <.link
                  navigate={
                    ~p"/hotel/book?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&room_type=#{room_type.type}"
                  }
                  class="text-white text-xl bg-[#2EAFA0] hover:bg-[#2A9D8F] transition duration-300 focus:ring-4 focus:ring-emerald-300 font-semibold rounded-lg px-7 py-3 focus:outline-none transition duration-300"
                >
                  Book now
                </.link>
              </div>
            </div>
          </div>
        </div>
      <% else %>
        <div class="text-2xl font-semibold text-center">
          Oops. Seems we have no room available for now.
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(
        %{"check_in_day" => check_in_day, "check_out_day" => check_out_day} = params,
        _session,
        socket
      ) do
    rooms =
      Rooms.list_available_room_types_with_room_count(params)
      |> Enum.sort_by(fn {room_type, _count} -> room_type.price.amount end)

    rooms_available? = Rooms.check_room_availability?(params)

    room_types = Rooms.list_room_types()

    {:ok,
     socket
     |> assign_form(params)
     |> assign(:rooms, rooms)
     |> assign(:room_types, room_types)
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
