ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/rails' # allows `describe` blocks
require 'mocha/minitest' # alows mocking
# require 'minitest/pride'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    ActionMailer::Base.deliveries.clear
  end

  # https://github.com/heartcombo/devise/wiki/How-To:-sign-in-and-out-a-user-in-Request-type-specs-(specs-tagged-with-type:-:request)
  include Devise::Test::IntegrationHelpers

  include ActiveJob::TestHelper
end
