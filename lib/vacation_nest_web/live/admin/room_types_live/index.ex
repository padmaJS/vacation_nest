defmodule VacationNestWeb.Admin.RoomTypesLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Rooms
  alias VacationNest.Hotels.RoomType
  import VacationNest.DisplayHelper

  def render(assigns) do
    ~H"""
    <.tabs>
      <:item text="Rooms" href={~p"/admin/rooms"} />
      <:item text="Room Types" href={~p"/admin/room_types"} current />
    </.tabs>

    <div class="px-5 relative ">
      <.link
        class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-1.5 mx-1 my-1.5 focus:outline-none transition duration-300 absolute right-0 top-0"
        patch={~p"/admin/room_types/new"}
      >
        Add Room Type
      </.link>
      <Flop.Phoenix.table
        opts={VacationNestWeb.FlopConfig.table_opts()}
        items={@streams.room_types}
        meta={@meta}
        path={~p"/admin/room_types"}
      >
        <:col :let={{_id, room_type}} field={:type} label="Type">
          <%= humanize_text(room_type.type) %>
        </:col>
        <:col :let={{_id, room_type}} field={:status} label="Price">
          <%= room_type.price %>
        </:col>
        <:col :let={{_id, room_type}} label="Image">
          <img src={room_type.image} class="w-[70px] h-[70px] mx-auto" />
        </:col>
        <:col :let={{_id, room_type}} label="Description">
          <%= room_type.description %>
        </:col>

        <:action :let={{id, room_type}}>
          <div class="flex space-x-2 justify-center">
            <.link
              class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
              patch={~p"/admin/room_types/#{room_type.id}/edit"}
            >
              Edit
            </.link>
            <.link
              class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
              phx-click={JS.push("delete", value: %{id: room_type.id}) |> hide("##{id}")}
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
          path={~p"/admin/room_types"}
        />
      </div>
    </div>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="room_type-edit-modal"
      show
      on_cancel={JS.patch(~p"/admin/room_types")}
    >
      <.live_component
        module={VacationNestWeb.Admin.RoomTypesLive.FormComponent}
        title={@title}
        id={@room_type.id || :new}
        action={@live_action}
        room_type={@room_type}
        patch={~p"/admin/room_types"}
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

  defp apply_action(socket, :edit, %{"id" => room_type_id}) do
    socket
    |> assign(:room_type, Rooms.get_room_type!(room_type_id))
    |> assign(:title, "Edit Room Type")
  end

  defp apply_action(socket, :new, _) do
    socket
    |> assign(:room_type, %RoomType{})
    |> assign(:title, "Add Room Type")
  end

  defp apply_action(socket, _, params) do
    %{room_types: room_types, meta: meta} =
      Rooms.list_room_types(params)

    socket
    |> stream(:room_types, room_types, reset: true)
    |> assign(:meta, meta)
  end

  def handle_event("delete", %{"id" => room_type_id}, socket) do
    room_type = Rooms.get_room_type!(room_type_id)
    {:ok, _room} = Rooms.delete_room_type(room_type)

    {:noreply, socket |> stream_delete(:room_types, room_type)}
  end

  def handle_info({_, {:saved, room_type}}, socket) do
    {:noreply, socket |> stream_insert(:room_types, room_type)}
  end
end
