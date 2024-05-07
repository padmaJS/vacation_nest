defmodule VacationNestWeb.HotelsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels
  alias VacationNest.Hotels.Review
  alias VacationNest.DisplayHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen min-w-screen bg-[url('/images/hotel_scenary1.jpg')] bg-cover grid grid-cols-4 grid-rows-3 justify-items-center">
      <!-- Appraisal and Basic Info -->
      <div class="col-span-2 row-start-2 col-start-1">
        <h1 class="text-7xl font-semibold">Vacation Nest</h1>
      </div>
      <div class="row-start-2 col-start-3 text-2xl font-semibold">
        <p class="text-gray-600">A cozy retreat in the heart of the city.</p>
        <p>Check-in: 2:00 PM</p>
        <p>Check-out: 11:00 AM</p>
        <p>Nasamana 13, Bhaktapur, Nepal</p>
      </div>
    </div>

    <div class="min-h-screen flex flex-col">
      <!-- Amenities -->
      <div class="bg-white p-4 mt-4">
        <h2 class="text-lg font-semibold">Our Services:</h2>
        <ul class="list-disc pl-4">
          <li>Free Wi-Fi</li>
          <li>Outdoor pool</li>
          <li>Fitness center</li>
          <!-- Add more amenities here -->
        </ul>
      </div>
    </div>
    <div class="min-h-screen flex flex-col">
      <!-- Contact Info -->
      <div class="bg-gray-100 p-4 mt-4">
        <h2 class="text-lg font-semibold">Contact Us</h2>
        <p>Phone: +1 123-456-7890</p>
        <p>Email: info@hotelxyz.com</p>
      </div>
    </div>
    <!-- lib/my_app_web/live/about_live.ex -->
    <div class="bg-gray-100 min-h-screen flex items-center justify-center">
      <div class="w-full max-w-md mx-auto p-6 bg-white rounded-lg shadow-lg">
        <h1 class="text-3xl font-semibold mb-4">VacationNest</h1>
        <p class="text-gray-600 mb-4">Your tranquil escape in the heart of nature.</p>
        <div class="mb-4">
          <h2 class="text-lg font-semibold mb-2">Location</h2>
          <p class="text-gray-600">Nestled amidst lush forests, near the serene lake.</p>
        </div>
        <div class="mb-4">
          <h2 class="text-lg font-semibold mb-2">Amenities</h2>
          <ul class="list-disc list-inside text-gray-600">
            <li>Infinity pool with mountain views</li>
            <li>Spa and wellness center</li>
            <li>Hiking trails</li>
            <li>Restaurant serving farm-to-table cuisine</li>
          </ul>
        </div>
        <div>
          <h2 class="text-lg font-semibold mb-2">Check-in & Check-out</h2>
          <p class="text-gray-600">Check-in: 3:00 PM</p>
          <p class="text-gray-600">Check-out: 11:00 AM</p>
        </div>
      </div>
    </div>

    <div class="flex flex-col bg-gray-100 p-8 rounded-lg shadow-md">
      <div class="flex flex-row justify-between items-center">
        <h2 class="text-2xl font-bold text-gray-800">Vacation Nest</h2>
        <div class="flex space-x-2">
          <span class="inline-block px-2 py-1 rounded-full bg-green-500 text-white text-sm">
            Rating: <%= DisplayHelper.convert_to_normal(@rating) %>
          </span>
          <span class="inline-block px-2 py-1 rounded-full bg-gray-200 text-gray-700 text-sm">
            Reviews: <%= @ratings_count %>
          </span>
        </div>
      </div>
      <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Location:</span>
          <span class="font-medium text-gray-700">Nasamana-13, Bhaktapur</span>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Description:</span>
          <p class="text-gray-700">Lorem Ipsum</p>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Amenities:</span>
          <ul class="list-disc space-y-1 text-gray-700">
            <li>LOL</li>
          </ul>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Check-in:</span>
          <span class="font-medium text-gray-700">10:00 AM</span>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Check-out:</span>
          <span class="font-medium text-gray-700">9:00 PM</span>
        </div>
      </div>
    </div>

    <div class="flex flex-col bg-gray-100 p-8 rounded-lg shadow-md">
      <div :if={@current_user && !@user_review} class="mt-8 border-t border-gray-200 pt-4">
        <.link
          patch={~p"/hotel/add_review"}
          class="px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
        >
          Leave a Review?
        </.link>
      </div>
      <%= if @ratings_count != 0 do %>
        <h2 class="text-xl font-semibold text-gray-800 my-3">Reviews</h2>
        <div class="mt-4 border-t pt-4">
          <div :if={@user_review} class="flex flex-col border-b py-4 px-4 hover:bg-gray-100">
            <div class="flex items-center mb-2">
              <span class="font-bold text-gray-800"><%= @current_user.email %></span>
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
                    class="ml-2 px-2 py-1 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
                  >
                    Edit Your Review?
                  </.link>
                </span>
              </span>
            </div>
            <p class="text-gray-700 text-sm"><%= @user_review.comment %></p>
          </div>
          <%= for review <- @reviews do %>
            <div class="flex flex-col border-b py-4 px-4 hover:bg-gray-100">
              <div class="flex items-center mb-2">
                <span class="font-bold text-gray-800"><%= review.user.email %></span>
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
              <p class="text-gray-700 text-sm"><%= review.comment %></p>
            </div>
          <% end %>
        </div>
      <% else %>
        <p class="text-gray-700 text-sm mt-4">No reviews yet. Be the first to write one!</p>
      <% end %>
    </div>

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
      if socket.assigns.current_user,
        do: Hotels.list_reviews() |> Enum.filter(&(&1.user_id != socket.assigns.current_user.id)),
        else: Hotels.list_reviews()

    rating = Hotels.get_rating()

    {:ok,
     socket
     |> assign(:reviews, reviews)
     |> assign(:rating, rating)
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
