defmodule VacationNestWeb.UserProfileLive.Show do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper
  alias VacationNest.{Accounts, Repo}

  def render(assigns) do
    ~H"""
    <div class="container mx-auto w-[410px] p-4 mt-8 bg-gray-50 shadow-lg rounded-lg">
      <div class="grid grid-cols-1 gap-y-4 py-7 md:space-x-8 relative justify-items-center">
        <.link
          :if={@current_user && @current_user.id == @user.id}
          patch={~p"/users/settings"}
          class="absolute font-medium top-0 right-0 p-[8px] rounded-lg bg-gray-200 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-300"
        >
          Edit Profile
        </.link>
        <div class="flex flex-col space-y-4 py-4 items-center justify-center">
          <img
            class="w-40 h-40 rounded-full object-cover mx-auto"
            src={@user.profile_image || "/images/avatar-default.svg"}
            alt="Profile Picture"
          />
          <h2 class="text-2xl font-bold text-center md:text-left"><%= @user.name %></h2>
          <p class="text-gray-600 text-center md:text-left"><%= @user.email %></p>
        </div>
        <div class="flex-grow flex flex-col space-y-4">
          <div class="grid grid-cols-2 gap-x-8 gap-y-4">
            <div class="flex flex-row space-y-2 items-center">
              <p class="text-gray-500 font-semibold">Gender:</p>
            </div>
            <p><%= humanize_text(@user.gender) %></p>
            <div class="flex flex-row space-y-2">
              <p class="text-gray-500 font-semibold">Phone Number:</p>
            </div>
            <p><%= @user.phone_number %></p>
            <div class="flex flex-row space-y-2">
              <p class="text-gray-500 font-semibold">Role:</p>
            </div>
            <p><%= humanize_text(@user.role) %></p>
          </div>
        </div>
      </div>
    </div>
    <div
      :if={@current_user.role == :admin}
      class="p-4 grid grid-cols-1 justify-items-center gap-4 bg-gray-50 shadow-lg rounded-lg m-8 mx-auto w-[60%]"
    >
      <label class="text-2xl font-semibold border-b-2">Bookings</label>
      <.table id="bookings" rows={@user.bookings}>
        <:col :let={booking} label="Amount"><%= booking.total_amount %></:col>
        <:col :let={booking} label="Room">
          <%= Enum.at(booking.rooms, 0) |> Map.get(:room_type) |> Map.get(:type) |> humanize_text %> X <%= Enum.count(
            booking.rooms
          ) %>
        </:col>
        <:col :let={booking} label="Check in day"><%= booking.check_in_day %></:col>
        <:col :let={booking} label="Check out day"><%= booking.check_out_day %></:col>
        <:col :let={booking} label="Status"><%= humanize_text(booking.status) %></:col>
        <:col :let={booking} label="Timestamp"><%= format_date(booking.updated_at) %></:col>
      </.table>
    </div>
    """
  end

  def mount(_, _session, socket) do
    {:ok, socket |> assign(:current_page, :profile)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    user = Accounts.get_user!(id)
    {:noreply, assign(socket, user: user)}
  end

  def handle_params(_, _url, socket) do
    user = socket.assigns.current_user |> Repo.preload(bookings: [rooms: [:room_type]])
    {:noreply, assign(socket, user: user)}
  end
end
