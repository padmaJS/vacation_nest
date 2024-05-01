defmodule VacationNestWeb.HotelsLive.Index do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""

    """
  end

  @impl true
  def mount(%{"hotel" => hotel_params}, _session, socket) do
    room_count = Rooms.get_available_rooms(hotel_params)

    {:ok,
     socket
     |> assign_form(hotel_params)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: :hotel))
  end

  # @impl true
  # def handle_event("validate_and_search", %{"hotel" => hotel_params}, socket) do
  #   {:noreply, socket |> assign_form(hotel_params)}
  # end
end
