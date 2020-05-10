class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for game
    # stream_from "game_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def game
    Game.find(params[:game_id])
  end
end
