class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :categories
  has_many :turns
  has_rich_text :description

  validates :title, length: { minimum: 2, maximum: 100 }

  Selection = Struct.new(:category, :option)

  def ready_to_play?
    categories.size > 0 && has_enough_options?
  end

  def has_enough_options?
    categories.all? { |category| category.options.size > 1 }
  end

  def current_player
    last_turn&.user
  end

  def next_player
    return ordered_players.first unless current_player
    ordered_players[ordered_players.index(current_player) + 1] || ordered_players.first
  end

  def last_turn
    turns.last
  end

  def options
    categories.flat_map(&:options)
  end

  def ordered_players
    users.sort_by { |user| user.order_on(self) }
  end

  def play(current_user)
    last_turn_record = last_turn()
    this_turn = Turn.new(user: current_user, game: self)

    while true
      this_turn.selected_options = []
      categories.each do |category|
        this_turn.selected_options << SelectedOption.new(option: category.options.sample)
      end
      break unless last_turn_record.present? && this_turn.has_same_selected_options_as?(last_turn_record)
    end

    this_turn.save!
    last_turn_record&.destroy!
  end
end
