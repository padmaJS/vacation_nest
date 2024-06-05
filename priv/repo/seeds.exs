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

%VacationNest.Hotels.Hotel{id: id} =
  %VacationNest.Hotels.Hotel{
    name: "Vacation Nest",
    address: "Nasamana-13, Bhaktapur, Nepal",
    checkin_time: ~T[14:00:00],
    checkout_time: ~T[11:00:00],
    phone_number: "9841152450",
    room_images: [
      "/images/rooms/room1.jpeg",
      "/images/rooms/room2.jpeg",
      "/images/rooms/room3.jpeg",
      "/images/rooms/room4.webp"
    ],
    amenities_images: [
      "/images/amenities/amenities1.jpg",
      "/images/amenities/amenities2.jpg",
      "/images/amenities/amenities3.jpg",
      "/images/amenities/amenities4.jpg",
      "/images/amenities/corridor.jpg"
    ],
    email: "info@vacation_nest.com",
    instagram_url: "https://www.instagram.com/vacation_nest/",
    facebook_url: "https://www.facebook.com/vacation_nest/"
  }
  |> Repo.insert!()

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
    room_type: single,
    hotel_id: id
  },
  %VacationNest.Hotels.Room{
    room_number: 2,
    room_type: single,
    hotel_id: id
  },
  %VacationNest.Hotels.Room{
    room_number: 3,
    room_type: double,
    hotel_id: id
  },
  %VacationNest.Hotels.Room{
    room_number: 4,
    room_type: double,
    hotel_id: id
  },
  %VacationNest.Hotels.Room{
    room_number: 5,
    room_type: double,
    hotel_id: id
  }
]
|> Enum.each(&Repo.insert!(&1))
