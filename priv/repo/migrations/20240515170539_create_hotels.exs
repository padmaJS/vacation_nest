defmodule VacationNest.Repo.Migrations.CreateHotels do
  use Ecto.Migration

  def change do
    create table(:hotels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :address, :string
      add :checkin_time, :time
      add :checkout_time, :time
      add :room_images, {:array, :string}
      add :amenities_images, {:array, :string}
      add :email, :string
      add :instagram_url, :string
      add :facebook_url, :string

      timestamps()
    end
  end
end
