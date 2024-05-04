defmodule VacationNest.Hotels.Booking do
  use VacationNest.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :total_amount, Money.Ecto.Amount.Type
    field :check_in_day, :date
    field :check_out_day, :date

    field :status, Ecto.Enum,
      values: [:requested, :confirmed, :on_going, :completed, :cancelled],
      default: :requested

    belongs_to :user, VacationNest.Accounts.User

    many_to_many :rooms, VacationNest.Hotels.Room, join_through: VacationNest.Hotels.BookingsRooms

    timestamps()
  end

  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:user_id, :total_amount, :check_in_day, :check_out_day, :status])
    |> validate_required([:user_id, :total_amount, :check_in_day, :check_out_day])
  end
end
