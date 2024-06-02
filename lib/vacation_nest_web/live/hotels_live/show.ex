defmodule VacationNestWeb.HotelsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels
  alias VacationNest.Hotels.Review
  alias VacationNest.DisplayHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen min-w-screen bg-[url('/images/hotel_scenary1.jpg')] bg-cover grid grid-cols-4 grid-rows-3 justify-items-center">
      <div class="col-span-2 row-start-2 col-start-1">
        <h1 class="text-7xl font-semibold"><%= @hotel.name %></h1>
      </div>
      <div class="row-start-2 col-start-3 text-2xl font-semibold">
        <p class="text-gray-600">Your Tranquil Escape in the Heart of Bhaktapur.</p>
        <p>Check-in: <%= DisplayHelper.format_time(@hotel.checkin_time) %></p>
        <p>Check-out: <%= DisplayHelper.format_time(@hotel.checkout_time) %></p>
        <p><%= @hotel.address %></p>
      </div>
    </div>

    <div class="grid grid-cols-2 justify-items-center p-4">
      <div class="grid grid-cols-1 bg-white p-4">
        <div>
          <h2 class="text-xl font-semibold">Experience the Charm of Bhaktapur at VacationNest</h2>
          <p class="text-lg mt-2">
            Nestled amidst the rich history and vibrant culture of Bhaktapur, VacationNest offers a haven for relaxation and exploration.  Just steps away from the famed Durbar Square, our hotel is your perfect base camp for experiencing the magic of this historic city. Step back in time and immerse yourself in the beauty of Newari architecture. Our elegantly appointed guest rooms, adorned with traditional Nepalese art and handcrafted furniture, offer a unique blend of modern comfort and timeless charm.
          </p>
        </div>
        <img src="/images/hotel_scenary3.jpeg" class="h-[500px] w-[500px] mx-auto" />
      </div>
      <div class="grid grid-cols-1">
        <img src="/images/hotel_scenary4.jpg" class="h-[500px] w-[500px] mx-auto" />
        <div>
          <h2 class="text-xl font-semibold">What we offer:</h2>
          <ul class="list-disc list-inside text-gray-600">
            <li :for={amenity <- @amenities}>
              <%= amenity %>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <div class="flex flex-col p-8 rounded-lg shadow-md">
      <div :if={@current_user && !@user_review} class="mt-8 border-t border-gray-200 pt-4">
        <.link
          patch={~p"/hotel/add_review"}
          class="px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
        >
          Leave a Review?
        </.link>
      </div>
      <h2 class="text-2xl font-semibold text-gray-800 my-3">Reviews</h2>
      <%= if @ratings_count != 0 do %>
        <div class="flex space-x-2">
          <span class="inline-block px-4 py-1 rounded-full bg-green-500 text-white text-xl">
            Rating: <%= DisplayHelper.convert_to_normal(@rating) %>
          </span>
          <span class="inline-block px-4 py-1 rounded-full bg-gray-200 text-gray-700 text-xl">
            Reviews: <%= @ratings_count %>
          </span>
        </div>
        <div class="mt-4 border-t pt-4">
          <div :if={@user_review} class="flex flex-col border-b py-4 px-4 hover:bg-gray-100">
            <div class="flex items-center mb-2">
              <span class="font-bold text-gray-800 text-lg flex space-x-1 items-center">
                <img src={@current_user.profile_image} class="w-[20px] h-[20px] rounded-full" />
                <p><%= @current_user.email %></p>
              </span>
              <span class="ml-2 text-yellow-500">
                <%= for _star <- 1..@user_review.rating do %>
                  &#9733;
                <% end %>
                <%= if @user_review.rating < 5 do %>
                  <%= for _star <- (@user_review.rating+1)..5 do %>
                    &#9734;
                  <% end %>
                <% end %>
                <%= DisplayHelper.format_year_month_day(@user_review.updated_at) %>
                <span :if={@user_review}>
                  <.link
                    patch={~p"/hotel/edit_review/#{@user_review}"}
                    class="ml-2 px-3 py-1.5 bg-blue-500 hover:bg-blue-700 text-white rounded-lg font-semibold"
                  >
                    Edit Your Review?
                  </.link>
                </span>
              </span>
            </div>
            <p class="text-gray-700 font-semibold"><%= @user_review.comment %></p>
          </div>
          <%= for review <- @reviews do %>
            <div class="flex flex-col border-b py-4 px-4 hover:bg-gray-100">
              <div class="flex items-center mb-2">
                <span class="font-bold text-gray-800 text-lg flex space-x-1 items-center">
                  <img src={review.user.profile_image} class="w-[20px] h-[20px] rounded-full" />
                  <a href={~p"/users/profile/#{review.user.id}"}>
                    <%= review.user.email %>
                  </a>
                </span>
                <span class="ml-2 text-yellow-500">
                  <%= for _star <- 1..review.rating do %>
                    &#9733;
                  <% end %>
                  <%= if review.rating < 5 do %>
                    <%= for _star <- (review.rating+1)..5 do %>
                      &#9734;
                    <% end %>
                  <% end %>
                  <%= DisplayHelper.format_year_month_day(review.updated_at) %>
                </span>
              </div>
              <p class="text-gray-700 font-semibold"><%= review.comment %></p>
            </div>
          <% end %>
        </div>
      <% else %>
        <p class="text-gray-700 text-sm mt-4">No reviews yet. Be the first to write one!</p>
      <% end %>
    </div>
    <.contact_us_footer hotel={Hotels.get_hotel()} />

    <.modal
      :if={@live_action in [:add_review, :edit_review]}
      id="review-modal"
      show
      on_cancel={JS.patch(~p"/hotel/about")}
    >
      <.live_component
        module={VacationNestWeb.HotelsLive.Review}
        action={@live_action}
        id="hotel-review"
        review={@review}
        current_user={@current_user}
        patch={~p"/hotel/about"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(
        _params,
        _session,
        socket
      ) do
    user_review =
      socket.assigns.current_user && Hotels.get_review_by_user(socket.assigns.current_user.id)

    reviews =
      if(socket.assigns.current_user,
        do: Hotels.list_reviews() |> Enum.filter(&(&1.user_id != socket.assigns.current_user.id)),
        else: Hotels.list_reviews()
      )
      |> Enum.sort(&(&1.rating >= &2.rating))

    rating = Hotels.get_rating()

    amenities = [
      "Restaurant with a menu showcasing regional cuisine",
      "Breakfast buffet with local specialties",
      "Themed cultural dinners with performances",
      "Rooms decorated in traditional styles",
      "Spa treatments inspired by traditional practices"
    ]

    {:ok,
     socket
     |> assign(:hotel, Hotels.get_hotel())
     |> assign(:reviews, reviews)
     |> assign(:rating, rating)
     |> assign(:amenities, amenities)
     |> assign(:ratings_count, Hotels.get_rating_count())
     |> assign(:user_review, user_review)
     |> assign(:current_page, :about)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :add_review, _params) do
    socket
    |> assign(:title, "Add Review")
    |> assign(:review, %Review{})
  end

  defp apply_action(socket, :edit_review, %{"review_id" => review_id}) do
    review = Hotels.get_review!(review_id)

    socket
    |> assign(:title, "Edit Review")
    |> assign(:review, review)
  end

  defp apply_action(socket, _index, _params) do
    socket
  end

  @impl true
  def handle_info({VacationNestWeb.HotelsLive.Review, {:saved, review}}, socket) do
    {:noreply,
     socket
     |> assign(:user_review, review)
     |> assign(:rating, Hotels.get_rating())
     |> assign(:ratings_count, Hotels.get_rating_count())}
  end
end
