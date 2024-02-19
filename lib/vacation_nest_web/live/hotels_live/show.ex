defmodule VacationNestWeb.HotelsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <.list>
      <:item title="Name"><%= @hotel.name %></:item>
      <:item title="Rating"><%= @hotel.rating %></:item>
      <:item title="Ratings count"><%= @hotel.ratings_count %></:item>
      <:item title="Location"><%= @hotel.location %></:item>
      <:item title="Description"><%= @hotel.description %></:item>
      <:item title="Verified"><%= @hotel.verified %></:item>
      <:item title="Amenities"><%= @hotel.amenities %></:item>
      <:item title="Website"><%= @hotel.website %></:item>
      <:item title="Check in time"><%= @hotel.check_in_time %></:item>
      <:item title="Check out time"><%= @hotel.check_out_time %></:item>
    </.list>
    """
  end

  @impl true
  def mount(%{"hotel_id" => hotel_id} = params, _session, socket) do
    hotel = Hotels.get_hotel!(hotel_id)

    {:ok,
     socket
     |> assign(:hotel, hotel)}

  end
end
