defmodule VacationNest.Hotels do
  import Ecto.Query, warn: false
  alias VacationNest.Repo

  alias VacationNest.Hotels.Hotel

  def list_hotels do
    Repo.all(Hotel)
  end

  def get_hotel!(id), do: Repo.get!(Hotel, id)

  def create_hotel(attrs \\ %{}) do
    %Hotel{}
    |> Hotel.changeset(attrs)
    |> Repo.insert()
  end

  def update_hotel(%Hotel{} = hotel, attrs) do
    hotel
    |> Hotel.changeset(attrs)
    |> Repo.update()
  end

  def delete_hotel(%Hotel{} = hotel) do
    Repo.delete(hotel)
  end

  def change_hotel(hotel \\ %Hotel{}, attrs \\ %{}) do
    Hotel.changeset(hotel, attrs)
  end
end
