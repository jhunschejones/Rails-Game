class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :async, :trackable, reconfirmable: true

  encrypts :email, :name
  blind_index :email, :name

  has_many :user_games
  has_many :games, through: :user_games
  has_many :turns

  validates :email, uniqueness: true
  validate :site_role_valid

  SITE_USER = "user".freeze
  SITE_ADMIN = "admin".freeze
  USER_SITE_ROLES = [SITE_USER, SITE_ADMIN].freeze

  def has_confirmed?(turn)
    turn.confirmed_by.include?(id)
  end

  def user_game_for(game_id)
    user_games.find { |user_game| user_game.game_id.to_s == game_id.to_s }
  end

  def player_order(game_id)
    user_game_for(game_id).order || 0
  end

  def can_access_game?(game_id)
    user_game_for(game_id).present?
  end

  def can_edit_game?(game_id)
    is_game_admin?(game_id)
  end

  def can_create_games?
    user_games.size < UserGame::MAX_USER_GAMES
  end

  def is_last_admin?(game)
    is_game_admin?(game.id) &&
      game.user_games.map(&:role).select { |role| role == UserGame::GAME_ADMIN }.size == 1
  end

  # Used for displaying "admin" label only, never directly for access control
  def is_game_admin?(game_id)
    user_games.find { |user_game| user_game.game_id.to_s == game_id.to_s &&
                                  user_game.role == UserGame::GAME_ADMIN }.present?
  end

  # --- LIBRARY OVERRIDES FOR SECURITY ---
  # Override default devise method to send emails using active job
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # This will allow enabling the :trackable Devise module without saving user IPs
  # https://github.com/heartcombo/devise/issues/4849#issuecomment-534733131
  def current_sign_in_ip; end
  def last_sign_in_ip=(_ip); end
  def current_sign_in_ip=(_ip); end

  private

  def site_role_valid
    unless USER_SITE_ROLES.include?(site_role)
      errors.add(:site_role, "not included in '#{USER_SITE_ROLES}'")
    end
  end
end
