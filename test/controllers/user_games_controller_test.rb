require 'test_helper'

# bundle exec ruby -Itest test/controllers/user_games_controller_test.rb
class UserGamesControllerTest < ActionDispatch::IntegrationTest
  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_game_user_game_path(games(:one), user_games(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has game player role" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
          @player_user_game = UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          get edit_game_user_game_path(games(:one), @player_user_game)
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "shows user game edit page" do
          get edit_game_user_game_path(games(:one), user_games(:one))
          assert_response :success
          assert_select "h2.title", /Edit player settings:/
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "does not update the UserGame record" do
        assert_no_changes -> { UserGame.find(user_games(:one).id).order } do
          patch game_user_game_path(games(:one), user_games(:one)), params: { user_game: { order: 2 } }
        end
      end

      test "redirect to login page" do
        patch game_user_game_path(games(:one), user_games(:one)), params: { user_game: { order: 2 } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has game player role" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
          @player_user_game = UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "does not update the UserGame record" do
          assert_no_changes -> { UserGame.find(@player_user_game.id).order } do
            patch game_user_game_path(games(:one), @player_user_game), params: { user_game: { order: 2 } }
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          patch game_user_game_path(games(:one), @player_user_game), params: { user_game: { order: 2 } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "updates a users order" do
          assert_changes -> { UserGame.find(user_games(:two).id).order } do
            patch game_user_game_path(games(:one), user_games(:two)), params: { user_game: { order: 3 } }
          end
        end

        test "updates a users role" do
          assert_changes -> { UserGame.find(user_games(:two).id).role } do
            patch game_user_game_path(games(:one), user_games(:two)), params: { user_game: { role: "admin" } }
          end
        end

        test "doesnt allow admin to set themselves to player" do
          assert_no_changes -> { UserGame.find(user_games(:one).id).role } do
            patch game_user_game_path(games(:one), user_games(:one)), params: { user_game: { role: "player" } }
          end
        end

        test "redirects to game users page after update" do
          patch game_user_game_path(games(:one), user_games(:one)), params: { user_game: { order: 2 } }
          assert_redirected_to game_users_path(games(:one))
          follow_redirect!
          assert_select 'h2.title', /Manage players:/
        end
      end
    end
  end

  describe "#confirm_action_completed" do
    describe "when no user is logged in" do
      test "does not confirm turn completed" do
        assert_no_changes -> { Turn.find(games(:one).last_turn.id).confirmed_by } do
          post game_confirm_action_completed_path(games(:one), format: :js)
        end
      end

      test "responds with 401" do
        post game_confirm_action_completed_path(games(:one), format: :js)
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot access the game" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
        end

        test "does not confirm turn completed" do
          assert_no_changes -> { Turn.find(games(:one).last_turn.id).confirmed_by } do
            post game_confirm_action_completed_path(games(:one), format: :js)
          end
        end

        test "redirects to games page" do
          expected_message = "You do not have access to that game"
          post game_confirm_action_completed_path(games(:one), format: :js)
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user can access the game" do
        test "confirms turn completed" do
          assert_changes -> { Turn.find(games(:one).last_turn.id).confirmed_by } do
            post game_confirm_action_completed_path(games(:one), format: :js)
          end
          assert Turn.find(games(:one).last_turn.id).confirmed_by.include?(users(:one).id), "user is not listed as having confirmed the turn was completed"
        end

        test "responds with javascript" do
          post game_confirm_action_completed_path(games(:one), format: :js)
          assert_response :ok
          assert_match /text\/javascript/, response.content_type
        end
      end
    end
  end
end
