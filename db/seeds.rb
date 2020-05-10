# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if User.count == 0
  user = User.create!(name: "Josh", email: ENV['EMAIL_USERNAME'], password: ENV['DEV_PASSWORD'], password_confirmation: ENV['DEV_PASSWORD'], confirmed_at: Time.now.utc, site_role: User::SITE_ADMIN)
  game = Game.create!(title: "My First Game")
  UserGame.create(user: user, game: game, role: UserGame::GAME_ADMIN)

  game.categories << Category.new(title: "Action", order: 1)
  game.categories << Category.new(title: "Place", order: 2)
  game.save!

  read_option = Option.new(description: "Read")
  write_option = Option.new(description: "Write")
  game.categories.first.options << read_option
  game.categories.first.options << write_option
  game.save!

  outside_option = Option.new(description: "Outside")
  living_room_option = Option.new(description: "In the living room")
  game.categories.last.options << outside_option
  game.categories.last.options << living_room_option
  game.save!

  turn = Turn.create!(user: user, game: game)
  turn.selected_options << SelectedOption.new(option: read_option)
  turn.selected_options << SelectedOption.new(option: outside_option)
  turn.save!

  game.turns << turn
  game.save!
end
