desc "Remove archived games"
task :clean_archived_games => [ :environment ] do
  puts "Enqueueing GameCleanupJob"
  GameCleanupJob.perform_later
end
