class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_game
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def current_game
    Game.find(params[:game_id])
  end
end
