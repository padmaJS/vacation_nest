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

    <pre>Your total bill will be Rs. <%= @total_amount |> :erlang.float_to_binary(decimals: 2) %>

    Price per day is <%= Hotels.get_price_per_room(@hotel) |> :erlang.float_to_binary(decimals: 2) %>

    Number of days you will stay is <%= @number_of_days %>

    Number of rooms you will stay is <%= @number_of_rooms %>
    </pre>
    """
  end

  @impl true
  def mount(%{"hotel_id" => hotel_id} = params, _session, socket) do
    hotel = Hotels.get_hotel!(hotel_id)

    number_of_days =
      ((Date.from_iso8601!(params["check_out_day"])
        |> Date.diff(Date.from_iso8601!(params["check_in_day"]))) + 1)
      |> IO.inspect()

    total_amount =
      get_total_amount(hotel, number_of_days, String.to_integer(params["number_of_rooms"]))

    {:ok,
     socket
     |> assign(:hotel, hotel)
     |> assign(:number_of_days, number_of_days)
     |> assign(:total_amount, total_amount)
     |> assign(:number_of_rooms, params["number_of_rooms"])}
  end

  defp get_total_amount(hotel, number_of_days, number_of_rooms),
    do: Hotels.get_price_per_room(hotel) * number_of_days * number_of_rooms
end
