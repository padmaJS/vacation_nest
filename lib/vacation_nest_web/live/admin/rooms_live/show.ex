defmodule VacationNestWeb.Admin.RoomsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms
  alias VacationNest.Hotels.Room
  import VacationNest.DisplayHelper

  def render(assigns) do
    ~H"""

    """
  end

  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room!(id) |> IO.inspect()
    {:ok, socket |> assign(:current_page, :rooms) |> assign(:room, room)}
  end
end
