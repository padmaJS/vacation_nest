defmodule VacationNestWeb.Admin.RoomsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms
  import VacationNest.DisplayHelper

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-3/4 my-4">
        <div class="flex flex-col space-y-6">
          <div
            class="grid grid-cols-3 bg-gray-10 p-4 shadow-xl rounded-lg gap-4"
          >
            <img src={@room.room_type.image} class="w-[250px] h-[250px] object-cover" />
            <div class="grid grid-rows-2 gap-4">
              <div class="flex items-end space-x-2">
                <p class="text-xl text-gray-500">Room Number</p>
                <p class="text-2xl font-semibold"><%= @room.room_number %></p>
              </div>
              <div class="row-start-2">
                <p class="text-2xl font-semibold"><%= humanize_text(@room.room_type.type) %></p>
                <p class="text-gray-500"><%= @room.room_type.description %></p>
              </div>
            </div>
            <div class="grid grid-rows-2">
              <span class=" row-start-2 !text-nowrap">
                <p class="text-2xl font-semibold"><%= @room.room_type.price %></p>
                per night
              </span>
            </div>
          </div>
        </div>
      </div>
    <div
      class="p-4 grid grid-cols-1 justify-items-center gap-4 bg-gray-50 shadow-lg rounded-lg m-8 mx-auto w-[60%]"
    >
      <label class="text-2xl font-semibold border-b-2">Bookings</label>
      <.table id="bookings" rows={@bookings}>
        <:col :let={booking} label="Amount"><%= booking.total_amount %></:col>
        <:col :let={booking} label="Check in day"><%= booking.check_in_day %></:col>
        <:col :let={booking} label="Check out day"><%= booking.check_out_day %></:col>
        <:col :let={booking} label="Status"><%= humanize_text(booking.status) %></:col>
        <:col :let={booking} label="Timestamp"><%= format_date(booking.updated_at) %></:col>
      </.table>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room!(id)
    {:ok, socket |> assign(:current_page, :rooms) |> assign(:room, room) |> assign(:bookings, room.bookings)}
  end
end
