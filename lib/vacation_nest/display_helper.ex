defmodule VacationNest.DisplayHelper do
  use Timex

  def convert_to_normal(value), do: value |> :erlang.float_to_binary(decimals: 2)

  def format_year_month_day(date) do
    date
    |> Timex.format!("%y/%m/%d", :strftime)
  end

  def format_date(date_time, timezone \\ "Asia/Kathmandu") do
    date_time
    |> Timex.to_datetime()
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%b %e, %Y at %I:%M:%S %p", :strftime)
  end
end
