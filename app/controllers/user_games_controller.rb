class UserGamesController < ApplicationController
  before_action :authorize_user_game_access
  before_action :authorize_user_game_edit, except: [:confirm_action_completed]
  before_action :set_game, except: [:confirm_action_completed]

  def edit
    @user_game = UserGame.includes(:user, :game).find(params[:id])
  end

  def update
    user_game = UserGame.find(params[:id])
    user_game.update!(order: params[:user_game][:order])
    redirect_to game_users_path(@game)
  end

  def confirm_action_completed
    user_game = UserGame.includes(game: [:turns]).find(params[:id])
    turn = user_game.game.last_turn
    turn.confirmed_by << current_user.id
    turn.save!
    head :ok, content_type: "text/javascript"
  end

  private

  def set_game
    @game = Game.includes(:users).find(params[:game_id])
  end
end
