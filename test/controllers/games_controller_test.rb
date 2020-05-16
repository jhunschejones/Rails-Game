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
    describe "when no user is logged in" do
      test "redirect to login page" do
        get game_path(games(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user does not have a GameUser record for the game" do
        test "redirects to games page with message" do
          get game_path(games(:two))
          assert_redirected_to games_path
          assert_equal "You do not have access to that game", flash[:notice]
        end
      end

      describe "when user has a GameUser record for the game" do
        describe "when game does not have enough categories" do
          setup do
            categories(:one).destroy
          end

          test "redirects to categories edit page" do
            expected_message = "Set at least 2 options for each of your categories before you start!"

            get game_path(games(:one))
            assert_redirected_to game_categories_path(games(:one))
            follow_redirect!

            assert_select "h2.title", /Manage categories:/
            assert_equal expected_message, flash[:notice]
          end
        end

        describe "when game categories do not have enough options" do
          setup do
            options(:one).destroy
          end

          test "redirects to categories edit page" do
            expected_message = "Set at least 2 options for each of your categories before you start!"

            get game_path(games(:one))
            assert_redirected_to game_categories_path(games(:one))
            follow_redirect!

            assert_select "h2.title", /Manage categories:/
            assert_equal expected_message, flash[:notice]
          end
        end

        describe "when game has enough options and categories" do
          test "shows game page" do
            get game_path(games(:one))
            assert_response :success
            assert_select "h1.title", /#{games(:one).title}/
          end

          describe "when user has game player role" do
            setup do
              UserGame.where(game: games(:one), user: users(:one)).destroy_all
              UserGame.create!(game: games(:one), user: users(:one), role: "player")
            end

            test "does not show Edit game link" do
              get game_path(games(:one))
              assert_response :success
              assert_select "h1.title", /#{games(:one).title}/
            end
          end

          describe "when user has game admin role" do
            test "shows Edit game link" do
              get game_path(games(:one))
              assert_response :success
              assert_select "a.button", /Edit game/
            end
          end
        end
      end
    end
  end

  describe "#new" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get new_game_path
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has user site_role" do
        setup do
          users(:one).update!(site_role: "user")
        end

        test "redirects to games page" do
          expected_message = "You do not have permission to create games"
          get new_game_path
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has admin site_role" do
        test "shows new page" do
          get new_game_path
          assert_response :success
          assert_select "h2.title", /New game:/
        end
      end
    end
  end

  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_game_path(games(:one))
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
          UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          get edit_game_path(games(:one))
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "shows edit page" do
          get edit_game_path(games(:one))
          assert_response :success
          assert_select "h2.title", /Edit game:/
        end
      end
    end
  end

  describe "#create" do
    describe "when no user is logged in" do
      test "does not create a new game" do
        assert_no_difference 'Game.count' do
          post games_path, params: { game: { title: "My New Game" } }
        end
      end

      test "redirect to login page" do
        post games_path, params: { game: { title: "My New Game" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has the user site_role" do
        setup do
          users(:one).update!(site_role: "user")
        end

        test "redirects to games page" do
          expected_message = "You do not have permission to create games"
          post games_path, params: { game: { title: "My New Game" } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end

        test "does not create a new game" do
          assert_no_difference 'Game.count' do
            post games_path, params: { game: { title: "My New Game" } }
          end
        end

        test "does not create a new UserGame record" do
          assert_no_difference 'UserGame.count' do
            post games_path, params: { game: { title: "My New Game" } }
          end
        end
      end

      describe "when user has the admin site_role" do
        setup do
          users(:one).update!(site_role: "admin")
        end

        test "creats a new game" do
          assert_difference 'Game.count', 1 do
            post games_path, params: { game: { title: "My New Game" } }
          end
        end

        test "creates UserGame record with admin role" do
          assert_difference 'UserGame.count', 1 do
            post games_path, params: { game: { title: "My New Game" } }
          end
          assert_equal users(:one).id, UserGame.last.user.id
          assert_equal "admin", UserGame.last.role
        end

        test "redirects to game page, then catagories page to add categories" do
          post games_path, params: { game: { title: "My New Game" } }
          assert_redirected_to game_path(Game.last)
          follow_redirect!
          assert_redirected_to game_categories_path(Game.last)
          follow_redirect!
          assert_select "h2.title", /Manage categories:/
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "does not update the game" do
        assert_no_changes -> { Game.find(games(:one).id).title } do
          patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
        end
      end

      test "redirect to login page" do
        patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
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
          UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "does not update the game" do
          assert_no_changes -> { Game.find(games(:one).id).title } do
            patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "updates the game" do
          assert_changes -> { Game.find(games(:one).id).title } do
            patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
          end
        end

        test "redirects to game edit page" do
          patch game_path(games(:one)), params: { game: { title: "Lets Change The Title" } }
          assert_redirected_to edit_game_path(games(:one))
          assert_equal "Game saved!", flash[:success]
          follow_redirect!
          assert_select 'form input[name="game[title]"][value=?]', "Lets Change The Title"
        end
      end
    end
  end

  describe "#play" do
    describe "when no user is logged in" do
      test "does not play the game" do
        Game.any_instance.expects(:play).never()
        get play_game_path(games(:one)), xhr: true
      end

      test "responds with 401" do
        get play_game_path(games(:one)), xhr: true
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

        test "does not play the game" do
          Game.any_instance.expects(:play).never()
          get play_game_path(games(:one)), xhr: true
        end

        test "redirects to games page" do
          expected_message = "You do not have access to that game"
          get play_game_path(games(:one)), xhr: true
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user can access the game" do
        test "plays the game" do
          Game.any_instance.expects(:play).times(1)
          get play_game_path(games(:one)), xhr: true
        end

        test "responds with javascript success" do
          get play_game_path(games(:one)), xhr: true
          assert_response :success
          assert_match /text\/javascript/, response.content_type
        end
      end
    end
  end
end
