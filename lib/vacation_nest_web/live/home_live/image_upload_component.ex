defmodule VacationNestWeb.HomeLive.ImageUploadComponent do
  alias VacationNest.Hotels
  use VacationNestWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      <.simple_form
        for={%{}}
        phx-change="validate"
        phx-submit="save_images"
        phx-target={@myself}
        phx-value-action={@action}
      >
        <.live_file_input
          upload={@uploads.new_images}
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-[#325D79] focus:border-[#325D79] block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-[#325D79] dark:focus:border-[#325D79] mt-2"
        />
        <%= for entry <- @uploads.new_images.entries do %>
          <article class="upload-entry">
            <figure class="flex items-center">
              <.live_img_preview entry={entry} width="150" />
              <figcaption><%= entry.client_name %></figcaption>&nbsp;
              <button
                phx-target={@myself}
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
              >
                <svg
                  width="1.25rem"
                  height="1.25rem"
                  viewBox="0 0 1024 1024"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="#ff0000"
                  stroke="#ff0000"
                >
                  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                  <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                  <g id="SVGRepo_iconCarrier">
                    <path
                      fill="#dd3636"
                      d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                    >
                    </path>
                  </g>
                </svg>
              </button>
            </figure>
          </article>
          <.error :for={err <- upload_errors(@uploads.new_images, entry)}>
            <%= error_to_string(err) %>
          </.error>
        <% end %>
        <.error :for={err <- upload_errors(@uploads.new_images)}>
          <%= error_to_string(err) %>
        </.error>

        <div class="grid grid-cols-2">
          <div :for={image <- @current_images} class="flex flex-col space-y-2 my-4">
            <img src={image} class="w-[250px] h-[250px] object-cover" />
            <button
              phx-click="delete_image"
              phx-value-id={image}
              phx-target={@myself}
              class="self-center"
            >
              <svg
                width="1.25rem"
                height="1.25rem"
                viewBox="0 0 1024 1024"
                xmlns="http://www.w3.org/2000/svg"
                fill="#ff0000"
                stroke="#ff0000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <path
                    fill="#dd3636"
                    d="M160 256H96a32 32 0 0 1 0-64h256V95.936a32 32 0 0 1 32-32h256a32 32 0 0 1 32 32V192h256a32 32 0 1 1 0 64h-64v672a32 32 0 0 1-32 32H192a32 32 0 0 1-32-32V256zm448-64v-64H416v64h192zM224 896h576V256H224v640zm192-128a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32zm192 0a32 32 0 0 1-32-32V416a32 32 0 0 1 64 0v320a32 32 0 0 1-32 32z"
                  >
                  </path>
                </g>
              </svg>
            </button>
          </div>
        </div>
        <:actions>
          <.button
            type="submit"
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

  def update(%{action: :room_images, hotel: hotel} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_images, hotel.room_images)
     |> assign(:uploaded_files, [])
     |> allow_upload(:new_images, accept: ~w(.jpg .jpeg .png .webp), max_entries: 4)}
  end

  def update(%{action: :amenities_images, hotel: hotel} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_images, hotel.amenities_images)
     |> assign(:uploaded_files, [])
     |> allow_upload(:new_images, accept: ~w(.jpg .jpeg .png .webp), max_entries: 4)}
  end

  def handle_event("cancel-upload", %{"ref" => ref} = _, socket) do
    {:noreply, cancel_upload(socket, :new_images, ref)}
  end

  def handle_event("delete_image", %{"id" => id}, socket) do
    {:noreply, socket |> assign(:current_images, List.delete(socket.assigns.current_images, id))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save_images", %{"action" => action}, socket) do
    uploaded =
      consume_uploaded_entries(socket, :new_images, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:vacation_nest),
            "static",
            "images",
            "rooms",
            Path.basename(path)
          ])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, "/images/rooms/" <> Path.basename(dest)}
      end)

    case action do
      "room_images" ->
        Hotels.update_hotel(%{room_images: socket.assigns.current_images ++ uploaded})

      "amenities_images" ->
        Hotels.update_hotel(%{amenities_images: socket.assigns.current_images ++ uploaded})
    end

    notify_parent({:saved, socket.assigns.hotel})

    {:noreply, socket |> push_patch(to: socket.assigns.patch)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
