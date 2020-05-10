class GameBroadcastJob < ApplicationJob
  queue_as :default

  def perform(turn_id)
    # Fancy version, sending new data
    # @this_turn = Turn.includes(:game, selected_options: [option: [:category]]).find(turn_id)
    # GameChannel.broadcast_to Game.find(@this_turn.game_id), render_play_selections_for(@this_turn)
    # Basic version doing page reload:
    GameChannel.broadcast_to Turn.includes(:game).find(turn_id).game, {}
  end

  private

  def render_play_selections_for(this_turn)
    ApplicationController.renderer.render(partial: 'games/game_play_selections', locals: { this_turn: this_turn })
  end
end
