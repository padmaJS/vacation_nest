defmodule VacationNestWeb.Router do
  use VacationNestWeb, :router

  import VacationNestWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VacationNestWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VacationNestWeb do
    pipe_through :browser

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{VacationNestWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new

      live "/", HomeLive.Index, :home

      live "/hotel/check", HotelsLive.Index, :index
      live "/hotel/about", HotelsLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", VacationNestWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vacation_nest, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VacationNestWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VacationNestWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{VacationNestWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", VacationNestWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VacationNestWeb.UserAuth, :ensure_authenticated}] do
      live "/users/profile", UserProfileLive.Show, :show
      live "/users/profile/:id", UserProfileLive.Show, :show

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/hotel/book", HotelsLive.Index, :book
      live "/hotel/add_review", HotelsLive.Show, :add_review
      live "/hotel/edit_review/:review_id", HotelsLive.Show, :edit_review

      live "/hotel/my_bookings", BookingsLive.Index, :my_bookings
    end

    live_session :require_authenticated_admin,
      on_mount: [
        {VacationNestWeb.UserAuth, :ensure_authenticated},
        {VacationNestWeb.Auth, :admin}
      ] do
      live "/hotel/bookings", BookingsLive.Index, :index

      live "/hotel/bookings/:id", BookingsLive.Show, :show

      scope "/admin", Admin do
        live "/users", UsersLive.Index, :index
        live "/users/:id", UsersLive.Index, :edit

        live "/room_types", RoomTypesLive.Index, :index
        live "/room_types/new", RoomTypesLive.Index, :new
        live "/room_types/:id/edit", RoomTypesLive.Index, :edit

        live "/rooms", RoomsLive.Index, :index
        live "/rooms/new", RoomsLive.Index, :new
        live "/rooms/:id/edit", RoomsLive.Index, :edit

        live "/rooms/:id", RoomsLive.Show, :show
      end
    end
  end
end
