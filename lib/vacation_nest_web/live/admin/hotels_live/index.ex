defmodule VacationNestWeb.Admin.HotelsLive do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels

  def render(assigns) do
    ~H"""
    <div class=" w-[600px] mx-auto bg-gray-50 p-14 pb-8 my-5 shadow-2xl rounded-lg">
      <.header class="text-center">
        Hotel Details
        <:subtitle>Manage hotel details</:subtitle>
      </.header>

      <div class="space-y-12 divide-y pt-4">
        <div>
          <.simple_form for={@form} phx-submit="save" phx-change="validate">
            <.input field={@form[:address]} type="text" label="Address" required />
            <.input field={@form[:phone_number]} type="text" label="Phone Number" required />
            <.input field={@form[:email]} type="text" label="Email" required />
            <.input field={@form[:instagram_url]} type="text" label="Instagram" required />
            <.input field={@form[:facebook_url]} type="text" label="Facebook" required />
            <.input field={@form[:checkin_time]} type="time" label="Checkin Time" required />
            <.input field={@form[:checkout_time]} type="time" label="Checkout Time" required />

            <.button type="submit">Save Details</.button>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_, _, socket) do
    hotel_changeset = Hotels.change_hotel()
    {:ok, socket |> assign(:current_page, :dashboard) |> assign_form(hotel_changeset)}
  end

  def handle_event("validate", %{"hotel" => params}, socket) do
    changeset =
      Hotels.change_hotel(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign_form(changeset)}
  end

  def handle_event("save", %{"hotel" => hotel_params}, socket) do
    case Hotels.update_hotel(hotel_params) do
      {:ok, _hotel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hotel updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
