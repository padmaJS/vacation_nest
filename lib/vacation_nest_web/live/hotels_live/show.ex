defmodule VacationNestWeb.HotelsLive.Show do
  use VacationNestWeb, :live_view

  alias VacationNest.Hotels
  alias VacationNest.Hotels.Review
  alias VacationNest.DisplayHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col bg-gray-100 p-8 rounded-lg shadow-md">
      <div class="flex flex-row justify-between items-center">
        <h2 class="text-2xl font-bold text-gray-800"><%= @hotel.name %></h2>
        <div class="flex space-x-2">
          <span class="inline-block px-2 py-1 rounded-full bg-green-500 text-white text-sm">
            Rating: <%= DisplayHelper.convert_to_normal(@hotel.rating) %>
          </span>
          <span class="inline-block px-2 py-1 rounded-full bg-gray-200 text-gray-700 text-sm">
            Reviews: <%= @hotel.ratings_count %>
          </span>
        </div>
      </div>
      <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Location:</span>
          <span class="font-medium text-gray-700"><%= @hotel.location %></span>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Description:</span>
          <p class="text-gray-700"><%= @hotel.description %></p>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Verified:</span>
          <span class="font-medium text-green-500">
            <%= if @hotel.verified, do: "Yes", else: "No" %>
          </span>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Amenities:</span>
          <ul class="list-disc space-y-1 text-gray-700">
            <%= for amenity <- @hotel.amenities do %>
              <li><%= amenity %></li>
            <% end %>
          </ul>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Website:</span>
          <a href={@hotel.website} class="text-blue-500 hover:underline"><%= @hotel.website %></a>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Check-in:</span>
          <span class="font-medium text-gray-700"><%= @hotel.check_in_time %></span>
        </div>
        <div class="flex flex-col">
          <span class="text-gray-500 text-sm">Check-out:</span>
          <span class="font-medium text-gray-700"><%= @hotel.check_out_time %></span>
        </div>
      </div>
      <div class="mt-4 flex justify-end">
        <.link
          patch={
            ~p"/hotels/#{@hotel.id}/book?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
          }
          class="px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
        >
          Book Room
        </.link>
      </div>
    </div>

    <div class="flex flex-col bg-gray-100 p-8 rounded-lg shadow-md">
      <div :if={@current_user && !@user_review} class="mt-8 border-t border-gray-200 pt-4">
        <.link
          patch={
            ~p"/hotels/#{@hotel.id}/add_review?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
          }
          class="px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
        >
          Leave a Review?
        </.link>
      </div>
      <%= if @hotel.reviews != [] do %>
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
                    patch={
                      ~p"/hotels/#{@hotel.id}/edit_review/#{@user_review}?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
                    }
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
      :if={@live_action == :book}
      id="book_room-modal"
      show
      on_cancel={
        JS.patch(
          ~p"/hotels/#{@hotel.id}/details?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
        )
      }
    >
      <.live_component
        module={VacationNestWeb.HotelsLive.Book}
        action={@live_action}
        id={@hotel.id}
        hotel={@hotel}
        check_in_day={@check_in_day}
        check_out_day={@check_out_day}
        number_of_rooms={@number_of_rooms}
        patch={
          ~p"/hotels/#{@hotel.id}/details?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
        }
        current_user={@current_user}
      />
    </.modal>

    <.modal
      :if={@live_action in [:add_review, :edit_review]}
      id="review-modal"
      show
      on_cancel={
        JS.patch(
          ~p"/hotels/#{@hotel.id}/details?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
        )
      }
    >
      <.live_component
        module={VacationNestWeb.HotelsLive.Review}
        action={@live_action}
        id={@hotel.id}
        review={@review}
        current_user={@current_user}
        hotel={@hotel}
        patch={
          ~p"/hotels/#{@hotel.id}/details?check_in_day=#{@check_in_day}&check_out_day=#{@check_out_day}&number_of_rooms=#{@number_of_rooms}"
        }
      />
    </.modal>
    """
  end

  @impl true
  def mount(
        %{
          "hotel_id" => hotel_id,
          "check_in_day" => check_in_day,
          "check_out_day" => check_out_day,
          "number_of_rooms" => number_of_rooms
        } = params,
        _session,
        socket
      ) do
    hotel = Hotels.get_hotel!(hotel_id)

    user_review = socket.assigns.current_user &&
      Hotels.get_review_by_user_and_hotel(socket.assigns.current_user.id, hotel_id)

    reviews = if current_user = socket.assigns.current_user, do: hotel.reviews |> Enum.filter(&(&1.user_id != current_user.id)), else: hotel.reviews


    {:ok,
     socket
     |> assign(:hotel, hotel)
     |> assign(:reviews, reviews)
     |> assign(:user_review, user_review)
     |> assign(:check_out_day, check_out_day)
     |> assign(:check_in_day, check_in_day)
     |> assign(:number_of_rooms, number_of_rooms)}
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
  def handle_event("book_room", _params, socket) do
    if socket.assigns.current_user do
      number_of_days =
        (Date.from_iso8601!(socket.assigns.check_out_day)
         |> Date.diff(Date.from_iso8601!(socket.assigns.check_in_day))) + 1

      total_amount =
        get_total_amount(
          socket.assigns.hotel,
          number_of_days,
          String.to_integer(socket.assigns.number_of_rooms)
        )

      attrs =
        socket.assigns
        |> Map.put(:total_amount, total_amount)
        |> Map.put(:user_id, socket.assigns.current_user.id)
        |> Map.put(:hotel_id, socket.assigns.hotel.id)

      Hotels.create_booking(attrs)

      {:noreply, socket |> push_patch(to: ~p"/hotels/#{socket.assigns.hotel.id}/details")}
    else
      {:noreply, socket |> push_navigate(to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_info({VacationNestWeb.HotelsLive.Review, {:saved, review}}, socket) do
    {:noreply,
     socket |> assign(:user_review, review) |> assign(:hotel, Hotels.get_hotel!(review.hotel_id))}
  end

  defp get_total_amount(hotel, number_of_days, number_of_rooms),
    do: Hotels.get_price_per_room(hotel) * number_of_days * number_of_rooms

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
