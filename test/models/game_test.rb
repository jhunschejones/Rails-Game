require 'test_helper'

# bundle exec ruby -Itest test/models/game_test.rb
class GameTest < ActiveSupport::TestCase
  describe "when deleting a game" do
    test "related UserGame records are cleaned up" do
      assert games(:one).user_games.size > 0, "there are no user_game fixtures to test"
      assert_difference 'UserGame.count', -games(:one).user_games.size do
        games(:one).destroy
      end
    end

    test "related Turn records are cleaned up" do
      assert games(:one).turns.size > 0, "there are no turn fixtures to test"
      assert_difference 'Turn.count', -games(:one).turns.size do
        games(:one).destroy
      end
    end

    test "related Category records are cleaned up" do
      assert games(:one).categories.size > 0, "there are no category fixtues to test"
      assert_difference 'Category.count', -games(:one).categories.size do
        games(:one).destroy
      end
    end

    test "related Option records are cleaned up" do
      assert games(:one).options.size > 0, "there are no option fixtues to test"
      assert_difference 'Option.count', -games(:one).options.size do
        games(:one).destroy
      end
    end

    test "related SelectedOption records are cleaned up" do
      assert games(:one).last_turn.selected_options.size > 0, "there are no selected_option fixtues to test"
      assert_difference 'SelectedOption.count', -games(:one).last_turn.selected_options.size do
        games(:one).destroy
      end
    end
  end
end
