require 'test_helper'

# bundle exec ruby -Itest test/models/turn_test.rb
class TurnTest < ActiveSupport::TestCase
  describe "when deleting a turn" do
    test "related SelectedOption records are cleaned up" do
      assert turns(:one).selected_options.size > 0, "there are no selected_option fixtures to test"
      assert_difference 'SelectedOption.count', -turns(:one).selected_options.size do
        turns(:one).destroy
      end
    end

    test "Option records are not affected" do
      assert games(:one).options.size > 0, "there are no option fixtures to test"
      assert_no_difference 'Option.count' do
        turns(:one).destroy
      end
    end
  end
end
