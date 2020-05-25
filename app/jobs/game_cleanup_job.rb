class GameCleanupJob < ApplicationJob
  queue_as :default

  def perform
    puts "GameCleanupJob is deleting games archived longer than 14 days ago"
    destroyed_games = Game.where("archived_on < ?", 14.days.ago).destroy_all
    puts "GameCleanupJob complete: #{destroyed_games.size} archived games deleted"
  end
end
