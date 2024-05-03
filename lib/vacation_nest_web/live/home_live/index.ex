defmodule VacationNestWeb.HomeLive.Index do
  use VacationNestWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-4 !w-9/12">
      <.form
        for={@form}
        action={~p"/hotel/check"}
        method="get"
        phx-change="validate"
        class="flex justify-around p-8 items-center"
      >
        <div class="flex justify-between w-5/12">
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
              min={@form[:check_in_day].value || @tomorrow}
              value={@form[:check_out_day].value || @tomorrow}
            />
          </div>
        </div>
        <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 mt-8 rounded-lg shadow-sm">
          Check
        </button>
      </.form>
    </div>
    <.header class="text-center">
      Welcome to Vacation Nest
    </.header>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today() |> Date.to_string()
    tomorrow = Date.utc_today() |> Date.add(1) |> Date.to_string()

    {:ok,
     socket
     |> assign(:current_page, :home)
     |> assign(:today, today)
     |> assign(:tomorrow, tomorrow)
     |> assign_form()}
  end

  defp assign_form(socket, changeset \\ %{}) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", hotel_params, socket) do
    {:noreply, socket |> assign_form(hotel_params)}
  end
end
