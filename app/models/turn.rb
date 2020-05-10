class Turn < ApplicationRecord
  belongs_to :user
  belongs_to :game
  has_many :selected_options

  after_save :enqueue_update

  def completed?
    game.users.size - 1 == confirmed_by.uniq.size
  end

  def has_same_selected_options_as?(other_turn)
    sorted_options == other_turn.sorted_options
  end

  def options
    selected_options.collect(&:option)
  end

  def sorted_options
    options.sort { |option| option.category.order }
  end

  private

  def enqueue_update
    puts "Enqueuing game broadcast job"
    GameBroadcastJob.perform_later(game_id)
  end
end
