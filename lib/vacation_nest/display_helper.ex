defmodule VacationNest.DisplayHelper do
  use Timex

  def convert_to_normal(value), do: value |> :erlang.float_to_binary(decimals: 2)

  def format_year_month_day(date) do
    date
    |> Timex.format!("%y/%m/%d", :strftime)
  end

  def format_date(date_time) do
    Timex.format!(date_time, "%b %e, %Y at %H:%M:%S %p", :strftime)
  end
end
