class GamesController < ApplicationController
  before_action :authorize_user_game_access, except: [:index, :new, :create]
  before_action :authorize_user_game_edit, only: [:edit, :update]
  before_action :authorize_user_game_create, only: [:new, :create]
  before_action :set_game, except: [:index, :new, :create]
  before_action :confirm_ready_for_game_play, only: [:show]

  def index
    @games = current_user.games.includes(:users, categories: [:options])
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
    game = Game.create!(game_params)
    UserGame.create!(user: current_user, game: game, role: UserGame::GAME_ADMIN)
    redirect_to game_path(game)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_game_path, notice: e.message.split(": ")[1]
  end

  def update
    @game.update!(game_params)
    redirect_to edit_game_path(@game), success: "Game saved!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_game_path(@game), notice: e.message.split(": ")[1]
  end

  def play
    @game.play(current_user)
    head :ok, content_type: "text/javascript; charset=utf-8"
  end

  private

  def authorize_user_game_create
    unless current_user.can_create_games?
      redirect_to(games_path, notice: "You do not have permission to create games")
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
    @game = Game.includes(categories: [:options]).find(params[:id])
  end

  def game_params
    params.require(:game).permit(:title, :description, :requires_turn_complete_confirmation)
  end
end
