require 'test_helper'

# bundle exec ruby -Itest test/controllers/options_controller_test.rb
class OptionsControllerTest < ActionDispatch::IntegrationTest
  describe "#create" do
    describe "when no user is logged in" do
      test "does not create a new option" do
        assert_no_difference 'Option.count' do
          post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
        end
      end

      test "responds with 401" do
        post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has game player role" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
          UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "does not create a new option" do
          assert_no_difference 'Option.count' do
            post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "creates a new option" do
          assert_difference 'Option.count', 1 do
            post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
          end
        end

        test "cleans up previous turn" do
          assert_difference 'Turn.count', -1 do
            post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
          end
        end

        test "responds with javascript" do
          post game_category_options_path(games(:one), categories(:one), format: :js), params: { option: { description: "Quietly" } }
          assert_response :created
          assert_match /text\/javascript/, response.content_type
          assert_match /option_#{Option.last.id}/, response.body
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      test "does delete the option" do
        assert_no_difference 'Option.count' do
          delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
        end
      end

      test "responds with 401" do
        delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has game player role" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
          UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "does delete the option" do
          assert_no_difference 'Option.count' do
            delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "deletes the option" do
          assert_difference 'Option.count', -1 do
            delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
          end
        end

        test "cleans up previous turn" do
          assert_difference 'Turn.count', -1 do
            delete game_category_option_path(games(:one), categories(:one), options(:one), format: :js)
          end
        end

        test "responds with javascript" do
          option_to_delete = Option.last
          delete game_category_option_path(games(:one), categories(:one), option_to_delete.id, format: :js)
          assert_response :success
          assert_match /text\/javascript/, response.content_type
          assert_match /option_#{option_to_delete.id}/, response.body
        end
      end
    end
  end
end
