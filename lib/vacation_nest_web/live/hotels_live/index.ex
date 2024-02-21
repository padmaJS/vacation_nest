defmodule VacationNestWeb.HotelsLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate_and_search">
      <.input
        field={@form[:location]}
        type="select"
        label="Location"
        prompt="Select your location"
        options={["Bhaktapur", "Kathmandu", "Lalitpur"]}
        required
      />
      <.input field={@form[:check_in_day]} type="date" label="Checkin Day" required min={@today} />
      <.input
        field={@form[:check_out_day]}
        type="date"
        label="Checkout Day"
        required
        min={@form[:check_in_day].value || @today}
      />
      <.input field={@form[:number_of_rooms]} type="number" label="Number of rooms" required />

      <button>Search</button>
    </.form>

    <.table id="hotels" rows={@streams.hotels}>
      <:col :let={{_id, hotel}} label="Name"><%= hotel.name %></:col>
      <:col :let={{_id, hotel}} label="Rating"><%= hotel.rating %></:col>
      <:col :let={{_id, hotel}} label="Ratings count"><%= hotel.ratings_count %></:col>
      <:col :let={{_id, hotel}} label="Location"><%= hotel.location %></:col>
      <:col :let={{_id, hotel}} label="Verified"><%= hotel.verified %></:col>
      <:col :let={{_id, hotel}} label="Check in time"><%= hotel.check_in_time %></:col>
      <:col :let={{_id, hotel}} label="Check out time"><%= hotel.check_out_time %></:col>
      <:col :let={{_id, hotel}} label="Price Per Room">
        <%= Hotels.get_price_per_room(hotel) |> :erlang.float_to_binary(decimals: 2) %>
      </:col>
      <:action :let={{_id, hotel}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          navigate={
            ~p"/hotels/#{hotel.id}/details?check_in_day=#{@form[:check_in_day].value}&check_out_day=#{@form[:check_out_day].value}&number_of_rooms=#{@form[:number_of_rooms].value}"
          }
        >
          View Details
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(%{"hotel" => hotel_params}, _session, socket) do
    today = Date.utc_today() |> Date.to_string()

    {:ok,
     socket
     |> assign(:today, today)
     |> stream(:hotels, Hotels.list_hotels(hotel_params))
     |> assign_form(hotel_params)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: :hotel))
  end

  @impl true
  def handle_event("validate_and_search", %{"hotel" => hotel_params}, socket) do
    {:noreply, socket |> assign_form(hotel_params)}
  end
end
