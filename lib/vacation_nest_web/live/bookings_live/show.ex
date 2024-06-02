defmodule VacationNestWeb.BookingsLive.Show do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper
  alias VacationNest.Rooms

  def render(assigns) do
    ~H"""
    <div class="container mx-auto w-[410px] p-4 mt-8 bg-gray-50 shadow-lg rounded-lg">
      <div class="grid grid-cols-1 gap-y-4 py-7 md:space-x-8 relative justify-items-center">
        <div class="flex flex-col space-y-4 py-4 items-center justify-center">
          <img
            class="w-40 h-40 rounded-full object-cover mx-auto"
            src={@booking.user.profile_image}
            alt="Profile Picture"
          />
          <h2 class="text-2xl font-bold text-center md:text-left"><%= @booking.user.name %></h2>
          <p class="text-gray-600 text-center md:text-left"><%= @booking.user.email %></p>
        </div>
        <div class="flex-grow flex flex-col space-y-4">
          <div class="grid grid-cols-2 gap-x-8 gap-y-4">
            <div class="flex flex-row space-y-2 items-center">
              <p class="text-gray-500 font-semibold">Gender:</p>
            </div>
            <p><%= humanize_text(@booking.user.gender) %></p>
            <div class="flex flex-row space-y-2">
              <p class="text-gray-500 font-semibold">Phone Number:</p>
            </div>
            <p><%= @booking.user.phone_number %></p>
            <div class="flex flex-row space-y-2">
              <p class="text-gray-500 font-semibold">Role:</p>
            </div>
            <p><%= humanize_text(@booking.user.role) %></p>
          </div>
        </div>
      </div>
    </div>
    <div
      :if={@current_user.role == :admin}
      class="p-4 grid grid-cols-1 justify-items-center gap-4 bg-gray-50 shadow-lg rounded-lg m-8 mx-auto w-[60%]"
    >
      <label class="text-2xl font-semibold border-b-2">Booking Detail</label>
      <.table id="bookings" rows={[@booking]}>
        <:col :let={booking} label="Amount"><%= booking.total_amount %></:col>
        <:col :let={booking} label="Room NUmbers">
          <%= booking.rooms |> Enum.map(& &1.room_number) |> Enum.join(", ") %>
        </:col>
        <:col :let={booking} label="Check in day"><%= booking.check_in_day %></:col>
        <:col :let={booking} label="Check out day"><%= booking.check_out_day %></:col>
        <:col :let={booking} label="Status"><%= humanize_text(booking.status) %></:col>
        <:col :let={booking} label="Timestamp"><%= format_date(booking.updated_at) %></:col>
      </.table>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    booking = Rooms.get_booking!(id)

    {:ok, socket |> assign(:current_page, :bookings) |> assign(:booking, booking)}
  end
end
