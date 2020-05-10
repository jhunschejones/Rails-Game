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

  def can_access_game?(game_id)
    UserGame.where(user_id: id, game_id: game_id).exists?
  end

  def can_edit_game?(game_id)
    is_game_admin?(game_id)
  end

  # Used for displaying "admin" label only, never directly for access control
  def is_game_admin?(game_id)
    UserGame.where(user_id: id, game_id: game_id, role: UserGame::GAME_ADMIN).exists?
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
