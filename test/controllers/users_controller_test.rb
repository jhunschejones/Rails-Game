require 'test_helper'

# bundle exec ruby -Itest test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  describe "#index" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get game_users_path(games(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot access the game" do
        setup do
          UserGame.where(user: users(:one), game: games(:one)).destroy_all
        end

        test "redirects to games page with message" do
          get game_path(games(:two))
          assert_redirected_to games_path
          assert_equal "You do not have access to that game", flash[:notice]
        end
      end

      describe "when user can access the game" do
        test "shows game users page" do
          get game_users_path(games(:one))
          assert_response :success
          assert_select "h2.title", /Manage players:/
        end
      end
    end
  end

  describe "#show" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get user_path(users(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when the user page is for a different user" do
        test "it redirects to the correct user profile with a messsage" do
          get user_path(users(:two))
          assert_redirected_to user_path(users(:one))
          assert_equal "You cannot view other users profiles", flash[:alert]
          follow_redirect!
          assert_select "p", /#{users(:one).name}/
        end
      end

      describe "when the user page is for the current user" do
        test "it shows the user profile page" do
          get user_path(users(:one))
          assert_response :success
          assert_select "p", /#{users(:one).name}/
        end
      end
    end
  end

  describe "#add_to_game" do
    describe "when no user is logged in" do
      test "does not send an invite email" do
        assert_enqueued_jobs 0
        assert_enqueued_jobs 0 do
          post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
        end
      end

      test "does not add a user to the game" do
        assert_no_difference 'UserGame.count' do
          post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
        end
      end

      test "responds with 401" do
        post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
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

        test "does not send an invite email" do
          assert_enqueued_jobs 0
          assert_enqueued_jobs 0 do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          end
        end

        test "does not add a user to the game" do
          assert_no_difference 'UserGame.count' do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          end
        end

        test "redirects to games page with message" do
          post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          assert_redirected_to games_path
          assert_equal "You do not have access to that game", flash[:notice]
        end
      end

      describe "when user is a game player" do
        setup do
          UserGame.where(game: games(:one), user: users(:one)).destroy_all
          UserGame.create!(game: games(:one), user: users(:one), role: "player")
        end

        test "does not send an invite email" do
          assert_enqueued_jobs 0
          assert_enqueued_jobs 0 do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          end
        end

        test "does not add a user to the game" do
          assert_no_difference 'UserGame.count' do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          end
        end

        test "redirects to games page with message" do
          post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
          assert_redirected_to games_path
          assert_equal "You are not allowed to modify that game", flash[:notice]
        end
      end

      describe "when user is a game admin" do

        describe "when user to be added already exists" do

          describe "when the user to be added is already in the game" do
            test "the user is not re-invited to the app" do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              refute User.find(users(:two).id).invitation_token, "the invitation should not be re-generated"
            end

            test "does not send an invite email" do
              assert_enqueued_jobs 0
              assert_enqueued_jobs 0 do
                post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              end
            end

            test "does not add the user to the game a second time" do
              assert_equal UserGame.where(user: users(:two), game: games(:one)).count, 1
              assert_no_difference 'UserGame.count' do
                post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              end
            end

            test "responds with javascript" do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              assert_response :unprocessable_entity
              assert_match /text\/javascript/, response.content_type
              assert_match /Unable to add user/, response.body
            end
          end

          describe "when the user to be added is not in the game yet" do
            setup do
              UserGame.where(user: users(:two), game: games(:one)).destroy_all
            end

            test "the user is not re-invited to the app" do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              refute User.find(users(:two).id).invitation_token, "the invitation should not be re-generated"
            end

            test "the new user is notified via email" do
              assert_enqueued_jobs 0
              assert_enqueued_jobs 1 do
                post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              end
            end

            test "adds user to the game" do
              assert_difference 'UserGame.count', 1 do
                post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              end
              assert_equal users(:two).email, UserGame.last.user.email
            end

            test "responds with javascript" do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: users(:two).name, email: users(:two).email } }
              assert_response :success
              assert_match /text\/javascript/, response.content_type
              assert_match /user_#{users(:two).id}/, response.body
            end
          end
        end

        describe "when user to be added is a new user" do
          test "a new user is created" do
            assert_difference 'User.count', 1 do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
            end
            assert_equal "filbert@dafox.com", User.last.email
          end

          test "the new user is invited to the app" do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
            assert User.last.invitation_token
          end

          test "only the app invite email is sent (not the game invite)" do
            assert_enqueued_jobs 0
            assert_enqueued_jobs 1 do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
            end
          end

          test "the new user is added to the game" do
            assert_difference 'UserGame.count', 1 do
              post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
            end
            assert_equal "filbert@dafox.com", UserGame.last.user.email
          end

          test "responds with javascript" do
            post game_add_user_path(games(:one), format: :js), params: { user: { name: "Filbert", email: "filbert@dafox.com" } }
            new_user = User.last
            assert_equal "filbert@dafox.com", new_user.email
            assert_response :success
            assert_match /text\/javascript/, response.content_type
            assert_match /user_#{new_user.id}/, response.body
          end
        end
      end
    end
  end

  describe "#remove_from_game" do
    describe "when no user is logged in" do
      test "does not remove a user from the game" do
        assert_no_difference 'UserGame.count' do
          delete game_remove_user_path(games(:one), users(:two), format: :js)
        end
      end

      test "responds with 401" do
        delete game_remove_user_path(games(:one), users(:two), format: :js)
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

        test "does not remove a user from the game" do
          assert_no_difference 'UserGame.count' do
            delete game_remove_user_path(games(:one), users(:two), format: :js)
          end
        end

        test "redirects to games page with message" do
          delete game_remove_user_path(games(:one), users(:two), format: :js)
          assert_redirected_to games_path
          assert_equal "You do not have access to that game", flash[:notice]
        end
      end

      describe "when user can access the game" do
        describe "when user is a game player" do
          setup do
            UserGame.where(game: games(:one), user: users(:one)).destroy_all
            UserGame.create!(game: games(:one), user: users(:one), role: "player")
          end

          describe "when removing another user from a game" do
            test "does not remove another user from the game" do
              assert_no_difference 'UserGame.count' do
                delete game_remove_user_path(games(:one), users(:two), format: :js)
              end
            end

            test "redirects to games page with message" do
              delete game_remove_user_path(games(:one), users(:two), format: :js)
              assert_redirected_to games_path
              assert_equal "You are not allowed to modify that game", flash[:notice]
            end
          end

          describe "when removing themselves from a game" do
            test "removes a user from the game" do
              assert_difference 'UserGame.count', -1 do
                delete game_remove_user_path(games(:one), users(:one), format: :js)
              end
            end

            test "cleans up previous turn" do
              assert_difference 'Turn.count', -1 do
                delete game_remove_user_path(games(:one), users(:one), format: :js)
              end
            end

            test "responds with javascript" do
              user_game_to_delete = UserGame.where(game: games(:one), user: users(:one)).first
              delete game_remove_user_path(games(:one), users(:one), format: :js)
              assert_response :success
              assert_match /text\/javascript/, response.content_type
              assert_match /.user_game_#{user_game_to_delete.id}/, response.body
            end
          end
        end

        describe "when user is a game admin" do
          describe "when user to remove is not in the game" do
            setup do
              UserGame.where(user: users(:two), game: games(:one)).destroy_all
            end

            test "does not remove a user from the game" do
              assert_no_difference 'UserGame.count' do
                delete game_remove_user_path(games(:one), users(:two), format: :js)
              end
            end

            test "redirects to game users page with message" do
              delete game_remove_user_path(games(:one), users(:two), format: :js)
              assert_redirected_to game_users_path(games(:one))
              assert_equal "That player is not in this game yet", flash[:notice]
            end
          end

          describe "when user to remove is in the game" do
            test "removes a user from the game" do
              assert_difference 'UserGame.count', -1 do
                delete game_remove_user_path(games(:one), users(:two), format: :js)
              end
            end

            test "cleans up previous turn" do
              assert_difference 'Turn.count', -1 do
                delete game_remove_user_path(games(:one), users(:two), format: :js)
              end
            end

            test "responds with javascript" do
              delete game_remove_user_path(games(:one), users(:two), format: :js)
              assert_response :success
              assert_match /text\/javascript/, response.content_type
              assert_match /.user_#{users(:two).id}/, response.body
            end
          end

          describe "when admin is removing themselves" do
            describe "when user is the last admin in the game" do
              test "does not remove a user from the game" do
                assert_no_difference 'UserGame.count' do
                  delete game_remove_user_path(games(:one), users(:one), format: :js)
                end
              end

              test "redirects to game edit page with message" do
                delete game_remove_user_path(games(:one), users(:one), format: :js)
                assert_redirected_to edit_game_path(games(:one))
                assert_match /You are the last admin in this game/, flash[:notice]
              end
            end

            describe "when user is not the last admin in the game" do
              setup do
                user_games(:two).update!(role: "admin")
              end

              test "removes a user from the game" do
                assert_difference 'UserGame.count', -1 do
                  delete game_remove_user_path(games(:one), users(:one), format: :js)
                end
              end

              test "cleans up previous turn" do
                assert_difference 'Turn.count', -1 do
                  delete game_remove_user_path(games(:one), users(:one), format: :js)
                end
              end

              test "responds with javascript" do
                delete game_remove_user_path(games(:one), users(:one), format: :js)
                assert_response :success
                assert_match /text\/javascript/, response.content_type
                assert_match /.user_#{users(:one).id}/, response.body
              end
            end
          end
        end
      end
    end
  end
end
