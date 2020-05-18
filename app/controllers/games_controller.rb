class GamesController < ApplicationController
  before_action :authorize_user_game_access, except: [:index, :new, :create]
  before_action :authorize_user_game_edit, only: [:edit, :update, :destroy]
  before_action :authorize_user_game_create, only: [:new, :create]
  before_action :set_game, except: [:index, :new, :create]
  before_action :confirm_ready_for_game_play, only: [:show]

  def index
    @games = current_user.games.active.includes(:users, categories: [:options])
  end

  def show
    if @game.last_turn
      @this_turn = @game.last_turn
    end
  end

  def new
    @game = Game.new
  end

  def edit
  end

  def create
    ActiveRecord::Base.transaction do
      @game = Game.create!(game_params)
      UserGame.create!(user: current_user, game: @game, role: UserGame::GAME_ADMIN)
    end
    redirect_to game_path(@game)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_game_path, notice: e.message.split(": ")[1]
  end

  def update
    @game.update!(game_params)
    redirect_to edit_game_path(@game), success: "Game updated!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_game_path(@game), notice: e.message.split(": ")[1]
  end

  def destroy
    ActiveRecord::Base.transaction do
      @game.archive
      @game.user_games.destroy_all
      @game.turns.destroy_all
    end
    redirect_to games_path, success: "Your game has been archived. It will be permanently deleted in 14 days."
  end

  def play
    @game.play(current_user)
    head :ok, content_type: "text/javascript; charset=utf-8"
  end

  private

  def authorize_user_game_create
    unless current_user.can_create_games?
      redirect_to(games_path, notice: "You cannot be a part of more than 10 games. Please <a href='/users/#{current_user.id}#quit-game'>quit</a> or archive a game before you create a new one.")
    end
  end

  def confirm_ready_for_game_play
    return true if @game.ready_to_play?

    if current_user.can_edit_game?(@game.id)
      redirect_to game_categories_path(@game), notice: "Set at least 2 options for each of your categories before you start!"
    else
      redirect_to game_path(@game), notice: "The game admin has not finished setting up this game yet!"
    end
  end

  def set_game
    @game = Game.active.includes(categories: [:options], turns: [selected_options: [option: [:category]]]).find(params[:id])
  end

  def game_params
    params.require(:game).permit(:title, :description, :requires_turn_complete_confirmation)
  end
end
