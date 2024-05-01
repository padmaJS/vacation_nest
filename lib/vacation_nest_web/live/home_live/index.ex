defmodule VacationNestWeb.HomeLive.Index do
  use VacationNestWeb, :live_view

  import VacationNest.DisplayHelper
  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-4 !w-9/12">
      <.form
        for={@form}
        action={~p"/hotels"}
        method="get"
        phx-change="validate"
        class="flex justify-around p-8 items-center"
      >
        <div class="w-4/12">
          <.input
            field={@form[:location]}
            type="select"
            label="Location"
            prompt="Select your location"
            options={["Bhaktapur", "Kathmandu", "Lalitpur"]}
            required
            class="border rounded-md px-3 py-2 focus:outline-none focus:ring-blue-500 focus:ring-1"
          />
        </div>
        <div class="flex justify-between w-5/12">
          <div class="w-1/2">
            <.input
              field={@form[:check_in_day]}
              type="date"
              label="Checkin Day"
              required
              min={@today}
              value={@today}
            />
          </div>
          <div class="w-1/2">
            <.input
              field={@form[:check_out_day]}
              type="date"
              label="Checkout Day"
              required
              min={@form[:check_in_day].value || @today}
              value={@form[:check_out_day].value || @today}
            />
          </div>
        </div>
        <div class="flex justify-between w-1/4">
          <.input
            field={@form[:number_of_rooms]}
            type="number"
            label="Number of rooms"
            required
            value="1"
          />
          <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 mt-8 rounded-lg shadow-sm">
            Search
          </button>
        </div>
      </.form>
    </div>
    <.header class="text-center">
      Welcome to Vacation Nest
    </.header>

    <.table id="hotels" rows={@streams.hotels}>
      <:col :let={{_id, hotel}} label="Name"><%= hotel.name %></:col>
      <:col :let={{_id, hotel}} label="Rating"><%= convert_to_normal(hotel.rating) %></:col>
      <:col :let={{_id, hotel}} label="Ratings count"><%= hotel.ratings_count %></:col>
      <:col :let={{_id, hotel}} label="Location"><%= hotel.location %></:col>
      <:col :let={{_id, hotel}} label="Verified"><%= hotel.verified %></:col>
      <:col :let={{_id, hotel}} label="Check in time"><%= hotel.check_in_time %></:col>
      <:col :let={{_id, hotel}} label="Check out time"><%= hotel.check_out_time %></:col>
      <:action :let={{_id, hotel}}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          navigate={
            ~p"/hotels/#{hotel.id}/details?check_in_day=#{@today}&check_out_day=#{@today}&number_of_rooms=1"
          }
        >
          View Details
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today() |> Date.to_string()

    {:ok,
     socket
     |> assign(:current_page, :home)
     |> assign(:today, today)
     |> stream(:hotels, Hotels.list_hotels())
     |> assign_form()}
  end

  defp assign_form(socket, changeset \\ %{}) do
    assign(socket, :form, to_form(changeset, as: :hotel))
  end

  @impl true
  def handle_event("validate", %{"hotel" => hotel_params}, socket) do
    {:noreply, socket |> assign_form(hotel_params)}
  end
end
