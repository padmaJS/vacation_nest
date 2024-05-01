defmodule VacationNestWeb.HotelsLive.Book do
  use VacationNestWeb, :live_component
  import VacationNest.DisplayHelper

  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Book the room</.header>

      <.form for={%{}} phx-submit="book_room">
        <pre>Your total bill will be Rs. <%= @total_amount |> convert_to_normal() %>

        Price per day is <%= Hotels.get_price_per_room(@hotel) |> convert_to_normal() %>

        Number of days you will stay is <%= @number_of_days %>

        Number of rooms you will stay is <%= @number_of_rooms %>


        </pre>
        <.button
          class="text-white inline-flex items-center bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-emerald-600 dark:hover:bg-emerald-700 dark:focus:ring-emerald-800"
          phx-disable-with="Booking..."
        >
          Book now
        </.button>
        <.link
          patch={@patch}
          class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
        >
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  @impl true
  def update(
        %{
          check_in_day: check_in_day,
          check_out_day: check_out_day,
          number_of_rooms: number_of_rooms,
          hotel: hotel
        } = assigns,
        socket
      ) do
    number_of_days =
      (Date.from_iso8601!(check_out_day)
       |> Date.diff(Date.from_iso8601!(check_in_day))) + 1

    total_amount =
      get_total_amount(hotel, number_of_days, String.to_integer(number_of_rooms))

    {:ok,
     assign(socket, assigns)
     |> assign(:number_of_days, number_of_days)
     |> assign(:total_amount, total_amount)}
  end

  defp get_total_amount(hotel, number_of_days, number_of_rooms),
    do: Hotels.get_price_per_room(hotel) * number_of_days * number_of_rooms
end
