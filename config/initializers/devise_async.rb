# Instructions
# https://github.com/heartcombo/devise/wiki/How-To:-Send-devise-emails-in-background-(Resque,-Sidekiq-and-Delayed::Job)
# Devise::Async.backend = :sidekiq
#
# Fix for `NoMethodError: undefined method `backend=' for Devise::Async:Module`:
# https://github.com/mhfs/devise-async/issues/105#issuecomment-342458354
