class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :categories
  has_many :turns
  has_rich_text :description

  validates :title, length: { minimum: 2, maximum: 100 }

  Selection = Struct.new(:category, :option)

  def ready_to_play?
    categories.all? { |category| category.options.size > 1 }
  end

  def last_turn
    turns.last
  end
end
