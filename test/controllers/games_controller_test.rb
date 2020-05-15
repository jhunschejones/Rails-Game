require 'test_helper'

# bundle exec ruby -Itest test/controllers/games_controller_test.rb
class GamesControllerTest < ActionDispatch::IntegrationTest
  describe "#index" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get games_path
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      test "shows all games" do
        get games_path
        assert_response :success
        assert_select "a.game", /#{games(:one).title}/
      end

      describe "when user has the user site_role" do
        setup do
          users(:one).update!(site_role: "user")
        end

        test "does not show new game button" do
          get games_path
          assert_select "a", count: 0, text: /New game/
        end
      end

      describe "when user has the admin site_role" do
        setup do
          users(:one).update!(site_role: "admin")
        end

        test "shows new game button" do
          get games_path
          assert_select "a", /New game/
        end
      end
    end
  end

  describe "#show" do
  end

  describe "#new" do
  end

  describe "#edit" do
  end

  describe "#create" do
  end

  describe "#update" do
  end

  describe "#play" do
  end

  describe "#turn_completed" do
  end
end
