defmodule VacationNestWeb.UserRegistrationLive do
  use VacationNestWeb, :live_view

  alias VacationNest.Accounts
  alias VacationNest.Accounts.User

  def render(assigns) do
    ~H"""
    <div class=" w-[40%] mx-auto bg-gray-50 p-14 pb-8 my-5 shadow-2xl rounded-lg">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <div>
          <.label for="profile_image">Profile Image</.label>
          <.live_file_input
            upload={@uploads.profile_image}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-[#325D79] focus:border-[#325D79] block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-[#325D79] dark:focus:border-[#325D79] mt-2"
          />
          <%= for entry <- @uploads.profile_image.entries do %>
            <article class="upload-entry">
              <figure class="flex items-center">
                <.live_img_preview entry={entry} width="150" />
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  &times;
                </button>
              </figure>
            </article>
            <.error :for={err <- upload_errors(@uploads.profile_image, entry)}>
              <%= error_to_string(err) %>
            </.error>
          <% end %>
          <.error :for={err <- upload_errors(@uploads.profile_image)}>
            <%= error_to_string(err) %>
          </.error>
        </div>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:name]} type="text" label="Name" required />

        <.input
          field={@form[:gender]}
          label="Gender"
          type="select"
          options={["male", "female"]}
          prompt="Select your gender"
          required
        />

        <.input field={@form[:phone_number]} type="text" label="Phone Number" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
        />

        <:actions>
          <.button
            phx-disable-with="Creating account..."
            class="w-full bg-green-500 hover:bg-green-600 transition duration-300"
          >
            Create an account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> assign(:uploaded_files, [])
      |> allow_upload(:profile_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1
      )
      |> assign(:current_page, :register)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :profile_image, fn %{path: path}, _entry ->
        dest =
          Path.join([:code.priv_dir(:vacation_nest), "static", "uploads", Path.basename(path)])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    user_params =
      if uploaded_files != [],
        do: Map.put(user_params, "profile_image", List.first(uploaded_files)),
        else: user_params

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
