defmodule VacationNestWeb.HomeLive.Index do
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
        <div class="m-4 text-xl font-semibold">Take a glance at our rooms:</div>
        <div id="slideshow" class="flex overflow-x-scroll whitespace-nowrap scroll-smooth pb-4">
          <div class="flex items-center">
            <%= for picture <- @room_pictures do %>
              <img src={picture} class="w-screen h-64 object-cover mr-4" />
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
      <div class="m-4 text-xl font-semibold">Take a glance at our amenities:</div>
      <div id="slideshow" class="flex overflow-x-scroll whitespace-nowrap scroll-smooth pb-4">
        <div class="flex items-center">
          <%= for picture <- @amenities_pictures do %>
            <img src={picture} class="w-screen h-64 object-cover mr-4" />
          <% end %>
        </div>
      </div>
      <.contact_us_footer />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today() |> Date.to_string()
    tomorrow = Date.utc_today() |> Date.add(1) |> Date.to_string()

    room_pictures =
      Path.join([:code.priv_dir(:vacation_nest), "static", "images", "rooms"])
      |> File.ls!()
      |> Enum.map(fn x -> ~p"/images/rooms/#{x}" end)

    amenities_pictures =
      Path.join([:code.priv_dir(:vacation_nest), "static", "images", "amenities"])
      |> File.ls!()
      |> Enum.map(fn x -> ~p"/images/amenities/#{x}" end)

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
     |> assign(:tomorrow, tomorrow)
     |> assign(:description, description)
     |> assign(:room_pictures, room_pictures)
     |> assign(:amenities_pictures, amenities_pictures)
     |> assign_form()}
  end

  defp assign_form(socket, changeset \\ %{}) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", hotel_params, socket) do
    {:noreply, socket |> assign_form(hotel_params)}
  end

  defp get_tomorrow(nil), do: nil

  defp get_tomorrow(date) do
    date
    |> Date.from_iso8601!()
    |> Date.add(1)
  end
end
