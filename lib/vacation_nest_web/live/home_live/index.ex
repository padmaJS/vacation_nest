defmodule VacationNestWeb.HomeLive.Index do
  use VacationNestWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    Hello guyz
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :home)}
  end
end
