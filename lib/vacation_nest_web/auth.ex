defmodule VacationNestWeb.Auth do
  use VacationNestWeb, :verified_routes

  def on_mount(:admin, _params, _session, socket) do
    if admin?(socket.assigns.current_user) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp admin?(user), do: user && user.role == :admin
end
