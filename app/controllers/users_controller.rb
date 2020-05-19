class UsersController < ApplicationController
  before_action :authorize_user_game_access, except: [:show]
  before_action :authorize_user_game_edit, except: [:show, :remove_from_game]
  before_action :set_game, except: [:show]

  # GET /games/:game_id/users
  def index
    @new_user = User.new
  end

  # GET /users/:id
  def show
    if params[:id] != current_user.id.to_s
      redirect_to user_path(current_user.id), alert: "You cannot view other users profiles"
    end

    @user = current_user
    @user_games = UserGame.includes(:game).where(user: current_user)
  end

  # POST /games/:game_id/users
  def add_to_game
    @email = user_params[:email].strip

    @user = User.where(email: @email).first || begin
      new_user_name = user_params[:name].try(:strip)
      new_user_name = "New User" if new_user_name.blank?
      User.invite!({email: @email, name: new_user_name}, current_user)
    end

    @user_game = UserGame.where(game: @game, user: @user).first ||
                 UserGame.new(game: @game, user: @user)

    respond_to do |format|
      if !@user_game.persisted? && @user_game.save
        UserMailer.invite_to_game(@user.id, @game.id, current_user.id).deliver_later unless @user.invitation_token
        format.js
      else
        format.js { render :add_to_game, status: 422 }
      end
    end
  end

  # DELETE /games/:game_id/users/:user_id
  def remove_from_game
    @user_game = UserGame.includes(:user).where(user_id: params[:user_id], game_id: @game.id).first

    if @user_game&.user != current_user && !current_user.can_edit_game?(params[:game_id])
      return redirect_to(games_path, notice: "You are not allowed to modify that game")
    end

    return redirect_to game_users_path(@game), notice: "That player is not in this game yet" unless @user_game

    if @user_game.user == current_user && current_user.is_last_admin_on?(@game)
      return redirect_to edit_game_path(@game), notice: "You are the last admin in this game. You will either need to archive the game or assign another admin before quitting."
    end

    ActiveRecord::Base.transaction do
      @user_game.destroy!
      Turn.where(game: @game).destroy_all
    end
    respond_to(&:js)
  end

  private

  def set_game
    @game = Game.active.includes(:users, :user_games).find(params[:game_id])
  end

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
