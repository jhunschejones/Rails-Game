class CategoriesController < ApplicationController
  before_action :authorize_user_game_access
  before_action :authorize_user_game_edit
  before_action :set_game
  before_action :set_category, except: [:index, :create]

  def index
    @category = Category.new
  end

  def edit
    @option = Option.new
  end

  def create
    if @game.categories.size > 3
      redirect_to game_categories_path(@game), notice: "You cannot have more than 4 categories per-game"
    else
      last_category_order = @game.categories.collect(&:order).sort.last
      order = last_category_order.nil? ? 1 : last_category_order + 1
      Category.create!(categories_params.merge({game_id: @game.id, order: order}))
      @game.reload
      Turn.where(game: @game).destroy_all
      respond_to { |format| format.js { render :create, status: 201 } }
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to game_categories_path(@game), notice: e.message.split(": ")[1]
  end

  def update
    @category.update!(categories_params)
    redirect_to edit_game_category_path(@game), success: "Category saved!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_game_category_path(@game), notice: e.message.split(": ")[1]
  end

  def destroy
    respond_to do |format|
      if @category.destroy
        Turn.where(game: @game).destroy_all
        format.js
      else
        format.js
      end
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def set_game
    @game = Game.active.includes(categories: [:options]).find(params[:game_id])
  end

  def categories_params
    params.require(:category).permit(:title, :order)
  end
end
