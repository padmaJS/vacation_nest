defmodule VacationNest.Repo do
  use Ecto.Repo,
    otp_app: :vacation_nest,
    adapter: Ecto.Adapters.Postgres
end
