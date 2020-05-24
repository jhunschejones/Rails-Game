class GameBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game_id:, perform_simple_refresh: false)
    @game = Game.active.includes(turns: [selected_options: [option: [:category]]]).where(id: game_id).first
    return unless @game

    if @game.requires_turn_complete_confirmation? || perform_simple_refresh
      # No data sent, just triggering page reload
      GameChannel.broadcast_to @game, {}
    else
      # Send new data for simpler case
      GameChannel.broadcast_to @game, {
        "gamePlaySections" => render_play_selections_for(@game.last_turn),
        "currentPlayer" => @game.current_player.name
      }
    end
  end

  private

  def render_play_selections_for(this_turn)
    ApplicationController.renderer.render(partial: 'games/game_play_selections', locals: { this_turn: this_turn })
  end
end
