defmodule VacationNestWeb.PartnershipLive.AddProperty do
  use VacationNestWeb, :live_component

  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Fill up the form to let us know about your property details.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="add_property-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Hotel Name" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:website]} type="url" label="Website" />
        <.input
          field={@form[:amenities]}
          type="select"
          multiple
          label="Amenities"
          options={["Free Wifi", "TV", "Parking Facility", "Power Backup", "CCTV", "Bar", "24/7 Checkin", "Attached Bathroom", "Security"]}
        />
        <.input field={@form[:check_in_time]} type="time" label="Checkin Time" />
        <.input field={@form[:check_out_time]} type="time" label="Checkout Time" />
        <:actions>
          <.button
            class="text-white inline-flex items-center bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-emerald-600 dark:hover:bg-emerald-700 dark:focus:ring-emerald-800"
            phx-disable-with="Saving..."
          >
            <svg
              class="mr-1 -ml-1 w-6 h-6"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z"
                clip-rule="evenodd"
              >
              </path>
            </svg>Add Property
          </.button>
          <.link
            patch={@patch}
            class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{hotel: hotel} = assigns, socket) do
    changeset = Hotels.change_hotel(hotel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"hotel" => hotel_params}, socket) do
    changeset =
      socket.assigns.hotel
      |> Hotels.change_hotel(hotel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"hotel" => hotel_params}, socket) do
    save_hotel(socket, socket.assigns.action, hotel_params)
  end

  defp save_hotel(socket, :edit, hotel_params) do
    case Hotels.update_hotel(socket.assigns.hotel, hotel_params) do
      {:ok, hotel} ->
        notify_parent({:saved, hotel})

        {:noreply,
         socket
         |> put_flash(:info, "Hotel updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_hotel(socket, :new, hotel_params) do
    case hotel_params |> Map.put("manager_id", socket.assigns.current_user.id) |> Hotels.create_hotel() do
      {:ok, hotel} ->
        notify_parent({:saved, hotel})

        {:noreply,
         socket
         |> put_flash(:info, "Hotel created successfully. Please wait for your approval.")
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
