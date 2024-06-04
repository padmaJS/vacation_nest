defmodule VacationNestWeb.BookingsLive.EditComponent do
  alias VacationNest.Rooms
  use VacationNestWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Edit Booking
      </.header>

      <.simple_form for={@form} id="booking-edit-form" phx-target={@myself} phx-submit="save">
        <.input
          field={@form[:status]}
          type="select"
          label="Role"
          options={[:requested, :confirmed, :on_going, :completed, :cancelled]}
          value={@booking.status}
        />
        <:actions>
          <.button
            class="text-white bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg px-5 py-1.5 transition duration-300"
            phx-disable-with="Saving..."
          >
            Save
          </.button>
          <.link
            patch={@patch}
            class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{booking: booking} = assigns, socket) do
    changeset = Rooms.change_booking(booking)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"booking" => booking_params}, socket) do
    save_booking(
      socket,
      socket.assigns.action,
      booking_params
    )
  end

  defp save_booking(socket, :edit, booking_params) do
    case Rooms.update_booking(socket.assigns.booking, booking_params) do
      {:ok, _booking} ->
        notify_parent(:update)

        {:noreply,
         socket
         |> put_flash(:info, "Booking updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
