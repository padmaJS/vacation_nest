# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VacationNest.Repo.insert!(%VacationNest.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias VacationNest.Repo
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

%VacationNest.Accounts.User{
  email: "admin@handin.org",
  role: :admin,
  hashed_password: Bcrypt.hash_pwd_salt("admin"),
  phone_number: "0",
  confirmed_at: now,
  profile_image: "https://picsum.photos/200"
}
|> Repo.insert!()

%VacationNest.Accounts.User{
  email: "guest1@gmail.com",
  role: :guest,
  hashed_password: Bcrypt.hash_pwd_salt("guest"),
  phone_number: "1",
  confirmed_at: now,
  profile_image: "https://picsum.photos/200"
}
|> Repo.insert!()

single =
  %VacationNest.Hotels.RoomType{
    type: :single,
    price: Money.new(100_000)
  }
  |> Repo.insert!()

double =
  %VacationNest.Hotels.RoomType{
    type: :double,
    price: Money.new(200_000)
  }
  |> Repo.insert!()

%VacationNest.Hotels.RoomType{
  type: :triple,
  price: Money.new(300_000)
}
|> Repo.insert!()

[
  %VacationNest.Hotels.Room{
    room_number: 1,
    room_type: single
  },
  %VacationNest.Hotels.Room{
    room_number: 2,
    room_type: single
  },
  %VacationNest.Hotels.Room{
    room_number: 3,
    room_type: double
  },
  %VacationNest.Hotels.Room{
    room_number: 4,
    room_type: double
  },
  %VacationNest.Hotels.Room{
    room_number: 5,
    room_type: double
  }
]
|> Enum.each(&Repo.insert!(&1))
