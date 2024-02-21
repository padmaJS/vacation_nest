defmodule VacationNestWeb.PartnershipLive.Index do
  alias VacationNest.Hotels
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels.Hotel
  alias VacationNest.Repo

  @impl true
  def render(assigns) do
    ~H"""
    Become a partner. You'll get benefits from us.......
    <.header class="text-center">
      Become a partner
      <:actions>
        <%= if @has_hotel do %>
          <.link patch={~p"/partnership/add_property/#{@hotel.id}/edit"}>
            <.button class="text-white bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3">
              Edit Property
            </.button>
          </.link>
        <% else %>
          <.link patch={~p"/partnership/add_property"}>
            <.button class="text-white bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg text-sm px-4 py-2 text-center mr-3 md:mr-0 mt-3">
              Add Property
            </.button>
          </.link>
        <% end %>
      </:actions>
    </.header>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="add_property-modal"
      show
      on_cancel={JS.patch(~p"/partnership")}
    >
      <.live_component
        module={VacationNestWeb.PartnershipLive.AddProperty}
        action={@live_action}
        id={(@has_hotel && @hotel.id) || :new}
        title={@title}
        hotel={@hotel}
        patch={~p"/partnership"}
        current_user={@current_user}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    hotel = socket.assigns.current_user |> Repo.preload(:hotel) |> Map.get(:hotel)

    {:ok,
     socket
     |> assign(:current_page, :partnership)
     |> assign(:has_hotel, hotel && true)
     |> assign(:hotel, hotel)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:title, "New Partnership")
    |> assign(:hotel, %Hotel{})
  end

  defp apply_action(socket, :edit, _) do
    hotel = socket.assigns.current_user |> Repo.preload(:hotel) |> Map.get(:hotel)

    socket
    |> assign(:title, "Edit Partnership")
    |> assign(:hotel, hotel)
  end

  defp apply_action(socket, _index, _params) do
    socket
  end

  @impl true
  def handle_info({VacationNestWeb.PartnershipLive.AddProperty, {:saved, hotel}}, socket) do
    {:noreply, assign(socket, :hotel, hotel) |> assign(:has_hotel, true)}
  end
end
