class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :categories
  has_many :turns
  has_rich_text :description

  after_update :update_game_channel

  validates :title, length: { minimum: 2, maximum: 100 }

  scope :active, -> { where(archived_on: nil) }

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
    users.sort_by { |user| user.player_order(id) }
  end

  def archive
    self.update!(archived_on: Time.zone.now)
  end

  def play(current_user)
    last_turn_record = last_turn

    # If playing in single-machine mode, assume each click is the next player
    this_turn = Turn.new(
      user: requires_turn_complete_confirmation ? current_user : next_player,
      game: self
    )

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

  private

  def update_game_channel
    if saved_change_to_requires_turn_complete_confirmation?
      # Refresh page for all players when game mode changes
      GameBroadcastJob.perform_later(game_id: id, perform_simple_refresh: true)
    end
  end
end
