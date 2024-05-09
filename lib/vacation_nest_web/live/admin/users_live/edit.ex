defmodule VacationNestWeb.Admin.UsersLive.Edit do
  use VacationNestWeb, :live_component

  alias VacationNest.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Edit User
      </.header>

      <.simple_form
        for={@form}
        id="user-edit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:name]} type="text" label="name" />
        <.input field={@form[:gender]} type="select" label="Gender" options={["male", "female"]} />
        <.input field={@form[:role]} type="select" label="Role" options={[:admin, :guest, :staff]} />
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
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.edit_changeset(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.edit_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(
      socket,
      socket.assigns.action,
      user_params
    )
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
