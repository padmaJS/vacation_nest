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
  hashed_password: Bcrypt.hash_pwd_salt("Hetauda_04"),
  phone_number: "0",
  confirmed_at: now
}
|> Repo.insert!()

%VacationNest.Accounts.User{
  email: "guest1@gmail.com",
  role: :guest,
  hashed_password: Bcrypt.hash_pwd_salt("guest"),
  phone_number: "1",
  confirmed_at: now
}
|> Repo.insert!()

[
  %VacationNest.Hotels.Room{
    price: 1000.0,
    room_number: 1,
    room_type: :single
  },
  %VacationNest.Hotels.Room{
    price: 1000.0,
    room_number: 2,
    room_type: :single
  },
  %VacationNest.Hotels.Room{
    price: 2000.0,
    room_number: 3,
    room_type: :double
  },
  %VacationNest.Hotels.Room{
    price: 2000.0,
    room_number: 4,
    room_type: :double
  }
]
|> Enum.each(&Repo.insert!(&1))
