defmodule VacationNest.DisplayHelper do
  def convert_to_normal(value), do: value |> :erlang.float_to_binary(decimals: 2)

  def format_year_month_day(date) do
    date
    |> Timex.format!("%y/%m/%d", :strftime)
  end
end
