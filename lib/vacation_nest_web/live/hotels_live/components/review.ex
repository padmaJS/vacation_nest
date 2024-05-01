defmodule VacationNestWeb.HotelsLive.Review do
  use VacationNestWeb, :live_component

  alias VacationNest.Hotels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Write a review</.header>

      <.form for={@form} phx-submit="save_review" phx-target={@myself}>
        <div class="flex items-center mb-4">
          <span class="text-gray-500 text-sm mr-2">Your Rating:</span>
          <.input
            field={@form[:rating]}
            name="rating"
            type="select"
            options={1..5}
            prompt="Select Rating"
            required
          />
        </div>
        <.input
          field={@form[:comment]}
          type="textarea"
          label="Comment"
          class="w-full rounded-md border border-gray-200 px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500"
        />
        <.button
          class="mt-4 px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white rounded-md font-semibold"
          phx-disable-with="Submitting..."
        >
          Submit Review
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = assigns[:review] |> Hotels.change_review()

    {:ok, socket |> assign(assigns) |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "save_review",
        %{"rating" => rating, "review" => %{"comment" => comment}},
        socket
      ) do
    save_review(
      socket,
      socket.assigns.action,
      %{"rating" => rating, "comment" => comment}
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("hotel_id", socket.assigns.hotel.id)
    )
  end

  defp save_review(socket, :edit_review, params) do
    case Hotels.update_review(socket.assigns.review, params) do
      {:ok, review} ->
        notify_parent({:saved, review})

        {:noreply,
         socket
         |> put_flash(:info, "Review updated successfully.")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp save_review(socket, :add_review, params) do
    case Hotels.create_review(params) do
      {:ok, review} ->
        notify_parent({:saved, review})

        {:noreply,
         socket
         |> put_flash(:info, "Review created successfully.")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
