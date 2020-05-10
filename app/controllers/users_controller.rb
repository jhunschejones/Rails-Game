class UsersController < ApplicationController
  before_action :authorize_user_game_access, except: [:show]
  before_action :authorize_user_game_edit, except: [:show]
  before_action :set_game, except: [:show]

  # GET /games/:game_id/users
  def index
    @new_user = User.new
  end

  # GET /users/:id
  def show
    if params[:id] != current_user.id.to_s
      redirect_to user_path(current_user.id), alert: "You cannot view other user's profiles."
    end

    @user = current_user
  end

  # GET /games/:game_id/users/:user_id/edit
  def edit
    @user = User.find(params[:id])
  end

  # PATCH /games/:game_id/users/:user_id
  def update
    user_game = UserGame.where(user_id: params[:user_id], game: @game).first
    user_game.update!(order: params[:order])
    redirect_to game_users_path(@game)
  end

  def add_to_game
    @email = user_params[:email].strip

    @user = User.where(email: @email).first || begin
      new_user_name = user_params[:name].try(:strip)
      new_user_name = "New User" if new_user_name.blank?
      User.invite!({email: @email, name: new_user_name}, current_user)
    end
    @user_game = UserGame.new(game: @game, user: @user)

    respond_to do |format|
      if @user_game.save
        UserMailer.invite_to_game(@user.id, @game.id, current_user.id).deliver_later unless @user.invitation_token
        format.js
      else
        format.js
      end
    end
  end

  def remove_from_game
    @user_game = UserGame.where(user_id: params[:user_id], game_id: @game.id).first
    return redirect_to game_users_path(@game), notice: "Player is not in this game" unless @user_game

    @user_game.destroy!
    respond_to(&:js)
  end

  private

  def set_game
    @game = Game.includes(:users, :user_games).find(params[:game_id])
  end

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
