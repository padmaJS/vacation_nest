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
      add :phone_number, :string
      add :rating, :float
      add :ratings_count, :integer
      add :verified, :boolean, default: false

      timestamps()
    end

      create unique_index(:hotels, [:email]). unique_index(:hotels, [:phone_number]), unique_index(:hotels, [:facebook_url]), unique_index(:hotels, [:instagram_url])
  end
end
