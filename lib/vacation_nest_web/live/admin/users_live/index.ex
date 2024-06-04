defmodule VacationNestWeb.Admin.UsersLive.Index do
  use VacationNestWeb, :live_view

  alias VacationNest.Accounts
  import VacationNest.DisplayHelper

  def render(assigns) do
    ~H"""
    <div class="px-5">
      <Flop.Phoenix.table
        opts={VacationNestWeb.FlopConfig.table_opts()}
        items={@streams.users}
        meta={@meta}
        path={~p"/admin/users"}
      >
        <:col :let={{_id, user}} field={:email} label="Email">
          <%= user.email %>
        </:col>
        <:col :let={{_id, user}} field={:name} label="Name">
          <%= user.name %>
        </:col>
        <:col :let={{_id, user}} label="Gender">
          <%= humanize_text(user.gender) %>
        </:col>
        <:col :let={{_id, user}} field={:role} label="Role">
          <%= humanize_text(user.role) %>
        </:col>
        <:col :let={{_id, user}} label="Created At">
          <%= format_date(user.inserted_at) %>
        </:col>

        <:action :let={{id, user}}>
          <div class="flex justify-center space-x-2">
            <.link
              class="text-white bg-[#325D79] hover:bg-[#527D99] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
              patch={~p"/admin/users/#{user.id}"}
            >
              Edit
            </.link>
            <.link
              class="text-white bg-[#325D99] hover:bg-[#527DAA] focus:ring-4 focus:ring-[#325D79] font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
              patch={~p"/users/profile/#{user.id}"}
            >
              Show
            </.link>
            <.link
              class="text-white bg-[#FF5427] hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg px-5 py-1.5 focus:outline-none transition duration-300"
              phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </div>
        </:action>
      </Flop.Phoenix.table>

      <div class="flex justify-center mt-5">
        <Flop.Phoenix.pagination
          opts={VacationNestWeb.FlopConfig.pagination_opts()}
          meta={@meta}
          path={~p"/admin/users"}
        />
      </div>
    </div>
    <.modal
      :if={@live_action == :edit}
      id="user-edit-modal"
      show
      on_cancel={JS.patch(~p"/admin/users")}
    >
      <.live_component
        module={VacationNestWeb.Admin.UsersLive.EditComponent}
        id={:edit}
        action={@live_action}
        user={@user}
        patch={~p"/admin/users"}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :users)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => user_id}) do
    socket
    |> assign(:user, Accounts.get_user!(user_id))
  end

  defp apply_action(socket, _, params) do
    %{users: users, meta: meta} =
      Accounts.list_users(params)

    socket
    |> stream(:users, users, reset: true)
    |> assign(:meta, meta)
  end

  def handle_event("delete", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket |> stream_delete(:users, user)}
  end
end
