class OptionsController < ApplicationController
  before_action :authorize_user_game_access
  before_action :authorize_user_game_edit
  before_action :set_game_and_category

  def create
    ActiveRecord::Base.transaction do
      @option = Option.create!(options_params.merge({category_id: @category.id}))
      Turn.where(game: @game).destroy_all
    end
    respond_to { |format| format.js { render :create, status: 201 } }
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_game_category_path(@game, @category), notice: e.message.split(": ")[1]
  end

  def destroy
    ActiveRecord::Base.transaction do
      @option = Option.find(params[:id])
      @option.destroy!
      Turn.where(game: @game).destroy_all
    end
    respond_to(&:js)
  end

  private

  def set_game_and_category
    @game = Game.active.find(params[:game_id])
    @category = Category.find(params[:category_id])
  end

  def options_params
    params.require(:option).permit(:description)
  end
end
