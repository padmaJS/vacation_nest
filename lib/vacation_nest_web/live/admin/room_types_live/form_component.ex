defmodule VacationNestWeb.Admin.RoomTypesLive.FormComponent do
  use VacationNestWeb, :live_component

  alias VacationNest.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="room_type-edit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <.label for="room_image">Room Image</.label>
          <.live_file_input
            upload={@uploads.room_image}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-[#325D79] focus:border-[#325D79] block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-[#325D79] dark:focus:border-[#325D79] mt-2"
          />
          <%= for entry <- @uploads.room_image.entries do %>
            <article class="upload-entry">
              <figure class="flex items-center">
                <.live_img_preview entry={entry} width="150" />
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  &times;
                </button>
              </figure>
            </article>
            <.error :for={err <- upload_errors(@uploads.room_image, entry)}>
              <%= error_to_string(err) %>
            </.error>
          <% end %>
          <.error :for={err <- upload_errors(@uploads.room_image)}>
            <%= error_to_string(err) %>
          </.error>
        </div>

        <.input
          field={@form[:room_type_id]}
          type="select"
          label="Room Type"
          options={Rooms.list_room_types() |> Enum.map(&{&1.type, &1.id})}
        />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[:available, :unavailable]}
        />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button
            class="text-white bg-emerald-700 hover:bg-emerald-800 focus:ring-4 focus:outline-none focus:ring-emerald-300 font-medium rounded-lg px-5 py-1.5 transition duration-300"
            phx-disable-with="Saving..."
          >
            Save
          </.button>
          <.link
            patch={@patch}
            class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{room_type: room_type} = assigns, socket) do
    changeset = Rooms.change_room_type(room_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:room_image,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1
     )}
  end

  @impl true
  def handle_event("validate", %{"room_type" => room_type_params}, socket) do
    changeset =
      socket.assigns.room_type
      |> Rooms.change_room_type(room_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"room_type" => room_type_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :room_image, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:vacation_nest),
            "static",
            "uploads",
            "room_type",
            Path.basename(path)
          ])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    room_type_params =
      if uploaded_files != [],
        do: Map.put(room_type_params, "room_image", List.first(uploaded_files)),
        else: room_type_params

    save_room_type(
      socket,
      socket.assigns.action,
      room_type_params
    )
  end

  defp save_room_type(socket, :edit, room_type_params) do
    case Rooms.update_room_type(socket.assigns.room_type, room_type_params) do
      {:ok, room_type} ->
        notify_parent({:saved, room_type})

        {:noreply,
         socket
         |> put_flash(:info, "Room type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_room_type(socket, :new, room_type_params) do
    case Rooms.create_room_type(room_type_params) do
      {:ok, room_type} ->
        notify_parent({:saved, room_type})

        {:noreply,
         socket
         |> put_flash(:info, "Room type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
