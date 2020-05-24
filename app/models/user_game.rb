class UserGame < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validate :game_role_valid
  validates_uniqueness_of :user_id, { scope: :game_id, message: "%{value} is already playing this game"}

  GAME_PLAYER = "player".freeze
  GAME_ADMIN = "admin".freeze
  USER_GAME_ROLES = [GAME_PLAYER, GAME_ADMIN].freeze
  MAX_USER_GAMES = 10.freeze

  def just_created?
    saved_change_to_attribute?(:id)
  end

  private

  def game_role_valid
    unless USER_GAME_ROLES.include?(role)
      errors.add(:role, "not included in '#{USER_GAME_ROLES}'")
    end
  end
end
