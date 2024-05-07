defmodule VacationNestWeb.BookingsLive.Index do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper
  alias VacationNest.Rooms

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <.table id="bookings" rows={@bookings}>
        <:col :let={booking} :if={@current_user.role == :admin} label="Email">
          <.link patch={~p"/users/profile/#{booking.user.id}"}><%= booking.user.email %></.link>
        </:col>
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
        <:action :let={booking}>
          <.button
            :if={
              @current_user.role == :admin and booking.status in [:cancelled, :requested] and
                Rooms.check_room_availability_for_booking?(booking)
            }
            class="text-white bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg px-5 py-1.5 transition duration-300"
            phx-disable-with="Accepting..."
            phx-click="accept_booking"
            phx-value-id={booking.id}
          >
            Accept
          </.button>
          <.button
            :if={
              @current_user.role == :admin and booking.status in [:requested, :confirmed, :on_going]
            }
            phx-disable-with="Cancelling..."
            phx-click="cancel_booking"
            phx-value-id={booking.id}
            class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
          >
            Cancel
          </.button>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:current_page, :bookings)}
  end

  defp apply_action(socket, :my_bookings, _params) do
    socket |> assign(:bookings, Rooms.list_bookings(socket.assigns.current_user.id))
  end

  defp apply_action(socket, _index, _params) do
    socket |> assign(:bookings, Rooms.list_bookings())
  end

  def handle_event("accept_booking", %{"id" => id}, socket) do
    Rooms.get_booking!(id)
    |> Rooms.update_booking(%{status: :confirmed})

    notify_self(:update)
    {:noreply, socket |> put_flash(:info, "Booking request accepted")}
  end

  def handle_event("cancel_booking", %{"id" => id}, socket) do
    Rooms.get_booking!(id)
    |> Rooms.update_booking(%{status: :cancelled})

    notify_self(:update)

    {:noreply, socket |> put_flash(:info, "Booking request cancelled")}
  end

  def handle_info({__MODULE__, :update}, socket) do
    if socket.assigns.current_user.role == :admin do
      {:noreply, socket |> assign(:bookings, Rooms.list_bookings())}
    else
      {:noreply, socket |> assign(:bookings, Rooms.list_bookings(socket.assigns.current_user.id))}
    end
  end

  defp notify_self(msg), do: send(self(), {__MODULE__, msg})
end
