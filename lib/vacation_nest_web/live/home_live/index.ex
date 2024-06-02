defmodule VacationNestWeb.HomeLive.Index do
  alias VacationNest.Hotels
  use VacationNestWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="absolute top-19 w-full">
      <div class="bg-[url('/images/hotel_scenary2.jpg')] bg-cover h-[400px] grid grid-rows-3">
        <div class="w-2/3 mx-auto row-start-2">
          <div class="container my-2 mx-auto px-4 py-4 !w-[80%]">
            <.form
              for={@form}
              action={~p"/hotel/check"}
              method="get"
              phx-change="validate"
              class="flex justify-center items-center"
            >
              <div class="flex justify-center w-3/4">
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
                    min={get_tomorrow(@form[:check_in_day].value) || @tomorrow}
                    value={@form[:check_out_day].value || @tomorrow}
                  />
                </div>
              </div>
              <.button class="bg-[#325D79] hover:bg-[#527D99] py-[9px] px-4 mt-8 rounded-md shadow-sm transition duration-300">
                Check Availability
              </.button>
            </.form>
          </div>
        </div>
      </div>
      <div class="h-[35%] my-10">
        <.header class="text-center">
          WELCOME TO VACATION NEST
          <:subtitle>Experience the Charm of Bhaktapur at VacationNest</:subtitle>
        </.header>
      </div>
      <div>
        <div class="flex">
          <div class="m-4 text-xl font-semibold">Take a glance at our rooms:</div>
          <.link
            :if={@current_user && @current_user.role == :admin}
            navigate={~p"/edit_room_images"}
            class="bg-[#325D79] hover:bg-[#527D99] py-[5px] text-white px-4 my-3 rounded-md shadow-sm transition duration-300"
          >
            Edit
          </.link>
        </div>
        <div id="slideshow" class="flex overflow-x-scroll whitespace-nowrap scroll-smooth pb-4">
          <div class="flex items-center">
            <%= for picture <- @hotel.room_images do %>
              <img src={picture} class="w-screen h-64 object-cover mr-2" />
            <% end %>
          </div>
        </div>
      </div>
      <section class="p-7">
        <div class="text-xl font-semibold py-1">Why choose us?</div>
        <ul class="list-disc">
          <li :for={{title, content} <- @description} class="p-1">
            <div class="font-semibold"><%= title %></div>
            <div><%= content %></div>
          </li>
        </ul>
      </section>
      <div class="flex">
        <div class="m-4 text-xl font-semibold">Take a glance at our amenities:</div>
        <.link
          :if={@current_user && @current_user.role == :admin}
          navigate={~p"/edit_amenities_images"}
          class="bg-[#325D79] hover:bg-[#527D99] py-[5px] text-white px-4 my-3 rounded-md shadow-sm transition duration-300"
        >
          Edit
        </.link>
      </div>
      <div id="slideshow" class="flex overflow-x-scroll whitespace-nowrap scroll-smooth pb-4">
        <div class="flex items-center">
          <%= for picture <- @hotel.amenities_images do %>
            <img src={picture} class="w-screen h-64 object-cover mr-2" />
          <% end %>
        </div>
      </div>
      <.contact_us_footer hotel={@hotel} />
    </div>
    <.modal
      :if={@live_action in [:amenities_images, :room_images]}
      id="images-edit-modal"
      show
      on_cancel={JS.patch(~p"/")}
    >
      <.live_component
        module={VacationNestWeb.HomeLive.ImageUploadComponent}
        id={:new}
        action={@live_action}
        title={@title}
        hotel={@hotel}
        patch={~p"/"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    hotel = Hotels.get_hotel()
    today = Date.utc_today() |> Date.to_string()
    tomorrow = Date.utc_today() |> Date.add(1) |> Date.to_string()

    description = [
      {"Immerse yourself in Newari culture",
       "Experience the heart of Bhaktapur at our hotel. We offer a unique blend of comfort, modern amenities, and opportunities to connect with the local culture."},
      {"Your Gateway to Authentic Experiences",
       "Go beyond the ordinary tourist experience. We offer curated tours, workshops, and activities that will immerse you in the rich tapestry of Bhaktapur's culture."},
      {"Live Like a Local",
       "Our hotel is more than just a place to stay. It's a chance to live like a local, surrounded by Bhaktapur's traditions, art, and cuisine."},
      {"Where History Meets Hospitality",
       "Steeped in the rich history of Bhaktapur, our hotel offers a unique blend of heritage charm and modern comfort. Discover the stories within our walls while enjoying exceptional hospitality."}
    ]

    {:ok,
     socket
     |> assign(:current_page, :home)
     |> assign(:today, today)
     |> assign(:hotel, hotel)
     |> assign(:tomorrow, tomorrow)
     |> assign(:description, description)
     |> assign_form()}
  end

  defp assign_form(socket, changeset \\ %{}) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :room_images, _params) do
    socket |> assign(:title, "Room Images")
  end

  defp apply_action(socket, :amenities_images, _params) do
    socket |> assign(:title, "Amenities Images")
  end

  defp apply_action(socket, _, _params) do
    socket
  end

  @impl true
  def handle_event("validate", hotel_params, socket) do
    {:noreply, socket |> assign_form(hotel_params)}
  end

  @impl true
  def handle_info({_, {:saved, _}}, socket) do
    {:noreply, assign(socket, :hotel, Hotels.get_hotel())}
  end

  defp get_tomorrow(nil), do: nil

  defp get_tomorrow(date) do
    date
    |> Date.from_iso8601!()
    |> Date.add(1)
  end
end
