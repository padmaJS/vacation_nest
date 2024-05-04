defmodule VacationNestWeb.BookingsLive.Index do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper
  alias VacationNest.Rooms

  def render(assigns) do
    ~H"""
    <h1>Bookings</h1>
    <.table id="bookings" rows={@bookings}>
      <:col :let={booking} :if={@current_user.role == :admin} label="Email">
        <%= booking.user.email %>
      </:col>
      <:col :let={booking} label="Amount"><%= booking.total_amount %></:col>
      <:col :let={booking} label="Room">
        <%= Enum.at(booking.rooms, 0) |> Map.get(:room_type) |> Map.get(:type) %> X <%= Enum.count(
          booking.rooms
        ) %>
      </:col>
      <:col :let={booking} label="Check in day"><%= booking.check_in_day %></:col>
      <:col :let={booking} label="Check out day"><%= booking.check_out_day %></:col>
      <:col :let={booking} label="Status"><%= booking.status %></:col>
      <:col :let={booking} label="Timestamp"><%= format_date(booking.updated_at) %></:col>
      <:action :let={booking}>
        <.button
          :if={@current_user.role == :admin}
          class="text-white inline-flex items-center bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-emerald-600 dark:hover:bg-emerald-700 dark:focus:ring-emerald-800"
          phx-disable-with="Accepting..."
          phx-click="accept_booking"
          phx-value-id={booking.id}
        >
          Accept
        </.button>
        <.button
          :if={
            (@current_user.role == :admin and booking.status in [:requested, :confirmed, :on_going]) or
              booking.status == :requested
          }
          phx-disable-with="Cancelling..."
          phx-click="cancel_booking"
          phx-value-id={booking.id}
          class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
        >
          Cancel
        </.button>
      </:action>
    </.table>
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
