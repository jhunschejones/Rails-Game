require 'test_helper'

# bundle exec ruby -Itest test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  describe "#is_last_admin?" do
    describe "when there is more than one admin in a game" do
      setup do
        user_games(:two).update!(role: "admin")
      end

      test "returns false" do
        refute users(:one).is_last_admin?(games(:one))
      end
    end

    describe "when user is the last admin in the game" do
      test "returns true" do
        assert users(:one).is_last_admin?(games(:one))
      end
    end
  end
end
