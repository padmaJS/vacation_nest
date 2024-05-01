defmodule VacationNest.Rooms do
  import Ecto.Query
  alias VacationNest.Repo
  alias VacationNest.Hotels.Room

  @check_in_time ~T[10:00:00]
  @check_out_time ~T[19:00:00]


  def get_available_rooms(%{"check_in_day" => check_in_day, "check_out_day" => check_out_day}) do
    now = Timex.now("Asia/Kathmandu") |> DateTime.to_time()
    today = Date.utc_today()

      query =
      Room
      |> join(:left, [r], b in assoc(r, :bookings))
      |> where(
        [r, b],
        is_nil(b.id) or b.check_in_day > ^check_in_day or
          b.check_out_day < ^check_out_day
      )

    query =
      if Date.from_iso8601!(check_in_day) == today do
        where(query, [r], ^@check_in_time > ^now)
      else
        query
      end

    query
    |> select([r, b], r)
    |> Repo.all()
    |> IO.inspect
  end
end
