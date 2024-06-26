defmodule VacationNestWeb.UserLoginLive do
  use VacationNestWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class=" w-1/3 mx-auto bg-gray-50 p-14 pb-8 my-5 shadow-2xl rounded-lg">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button
            phx-disable-with="Signing in..."
            class="w-full  bg-green-500 hover:bg-green-600  transition duration-300"
          >
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form) |> assign(:current_page, :login),
     temporary_assigns: [form: form]}
  end
end
