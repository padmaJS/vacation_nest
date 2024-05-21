defmodule VacationNestWeb.Admin.RoomsLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.{Rooms, Repo}
  alias VacationNest.Hotels.Room
  import VacationNest.DisplayHelper

  def render(assigns) do
    ~H"""
    <.tabs>
      <:item text="Rooms" href={~p"/admin/rooms"} current />
      <:item text="Room Types" href={~p"/admin/room_types"} />
    </.tabs>
    <div class="px-5 relative ">
      <.link
        class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-1.5 mx-1 my-1.5 focus:outline-none transition duration-300 absolute right-0 top-0"
        patch={~p"/admin/rooms/new"}
      >
        Add Room
      </.link>
      <Flop.Phoenix.table
        opts={VacationNestWeb.FlopConfig.table_opts()}
        items={@streams.rooms}
        meta={@meta}
        path={~p"/admin/rooms"}
      >
        <:col :let={{_id, room}} field={:room_number} label="Room Number">
          <%= room.room_number %>
        </:col>
        <:col :let={{_id, room}} field={:status} label="Status">
          <%= humanize_text(room.status) %>
        </:col>
        <:col :let={{_id, room}} label="Type">
          <%= humanize_text(room.room_type.type) %>
        </:col>
        <:col :let={{_id, room}} label="Created At">
          <%= format_date(room.inserted_at) %>
        </:col>

        <:action :let={{id, room}}>
          <div class="flex space-x-2 justify-center">
            <.link
              class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-3 mx-1 my-1.5 focus:outline-none transition duration-300"
              patch={~p"/admin/rooms/#{room.id}"}
            >
              Show
            </.link>
            <.link
              class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-3 mx-1 my-1.5 focus:outline-none transition duration-300"
              patch={~p"/admin/rooms/#{room.id}/edit"}
            >
              Edit
            </.link>
            <.link
              class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-3 mx-1 my-1.5 focus:outline-none transition duration-300"
              phx-click={JS.push("delete", value: %{id: room.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </div>
        </:action>
      </Flop.Phoenix.table>

      <div class="flex justify-center mt-5">
        <Flop.Phoenix.pagination
          opts={VacationNestWeb.FlopConfig.pagination_opts()}
          meta={@meta}
          path={~p"/admin/rooms"}
        />
      </div>
    </div>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="room-edit-modal"
      show
      on_cancel={JS.patch(~p"/admin/rooms")}
    >
      <.live_component
        module={VacationNestWeb.Admin.RoomsLive.FormComponent}
        title={@title}
        id={@room.id || :new}
        action={@live_action}
        room={@room}
        patch={~p"/admin/rooms"}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :rooms)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => room_id}) do
    socket
    |> assign(:room, Rooms.get_room!(room_id))
    |> assign(:title, "Edit Room")
  end

  defp apply_action(socket, :new, _) do
    socket
    |> assign(:room, %Room{})
    |> assign(:title, "Add Room")
  end

  defp apply_action(socket, _, params) do
    %{rooms: rooms, meta: meta} =
      Rooms.list_rooms(params)

    socket
    |> stream(:rooms, rooms, reset: true)
    |> assign(:meta, meta)
  end

  def handle_event("delete", %{"id" => room_id}, socket) do
    room = Rooms.get_room!(room_id)
    {:ok, _room} = Rooms.delete_room(room)

    {:noreply, socket |> stream_delete(:rooms, room)}
  end

  def handle_info({_, {:saved, room}}, socket) do
    {:noreply, socket |> stream_insert(:rooms, room |> Repo.preload([:room_type]))}
  end
end
