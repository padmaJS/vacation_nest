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
  email: "admin@admin.com",
  name: "Admin admin",
  role: :admin,
  hashed_password: Bcrypt.hash_pwd_salt("admin"),
  phone_number: "9841152450",
  confirmed_at: now,
  profile_image: "https://picsum.photos/200"
}
|> Repo.insert!()

1..30
|> Enum.each(fn i ->
  %VacationNest.Accounts.User{
    email: "guest#{i}@gmail.com",
    name: "Guest #{i}",
    gender: Enum.random(["male", "female"]),
    role: :guest,
    hashed_password: Bcrypt.hash_pwd_salt("guest"),
    phone_number: "98411524#{i}",
    confirmed_at: now,
    profile_image: "https://picsum.photos/200"
  }
  |> Repo.insert!()
end)

single =
  %VacationNest.Hotels.RoomType{
    type: "Single",
    price: Money.new(100_000),
    description: "Contains single bed with plenty of space",
    image: "/images/room_types/single.jpg"
  }
  |> Repo.insert!()

double =
  %VacationNest.Hotels.RoomType{
    type: "Double",
    price: Money.new(200_000),
    description: "Contains double bed",
    image: "/images/room_types/double.jpeg"
  }
  |> Repo.insert!()

%VacationNest.Hotels.RoomType{
  type: "Triple",
  price: Money.new(300_000),
  description: "Contains a single bed and a double bed",
  image: "/images/room_types/triple.jpg"
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
