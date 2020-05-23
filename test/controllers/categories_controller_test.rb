require 'test_helper'

# bundle exec ruby -Itest test/controllers/categories_controller_test.rb
class CategoriesControllerTest < ActionDispatch::IntegrationTest
  describe "#index" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get game_categories_path(games(:one))
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
          get game_categories_path(games(:one))
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "shows categories page" do
          get game_categories_path(games(:one))
          assert_response :success
          assert_select "h2.title", /Manage categories:/
        end
      end
    end
  end

  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_game_category_path(games(:one), categories(:one))
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
          get edit_game_category_path(games(:one), categories(:one))
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "shows edit category page" do
          get edit_game_category_path(games(:one), categories(:one))
          assert_response :success
          assert_select "h2.title", /Edit category:/
        end
      end
    end
  end

  describe "#create" do
    describe "when no user is logged in" do
      test "does not create a new category" do
        assert_no_difference 'Category.count' do
          post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
        end
      end

      test "responds with 401" do
        post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
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

        test "does not create a new category" do
          assert_no_difference 'Category.count' do
            post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        describe "when there are already 4 categories for the game" do
          setup do
            ActiveRecord::Base.transaction do
              Category.create!(game: games(:one), title: "Category 2")
              Category.create!(game: games(:one), title: "Category 3")
              Category.create!(game: games(:one), title: "Category 4")
            end
          end

          test "does not create a new category" do
            assert_no_difference 'Category.count' do
              post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            end
          end

          test "redirects to categories page with message" do
            expected_message = "You cannot have more than 4 categories per-game"
            post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            assert_redirected_to game_categories_path
            assert_equal expected_message, flash[:notice]
          end
        end

        describe "when there are less than 4 categories for the game already" do
          test "creates a new category" do
            assert_difference 'Category.count', 1 do
              post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            end
            assert_equal "Places to visit", Category.last.title
          end

          test "sets the catagory order to the next sequential number" do
            last_category = Category.last
            post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            assert_equal last_category.order + 1, Category.last.order
          end

          test "cleans up previous turn record" do
            assert_difference 'Turn.count', -1 do
              post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            end
          end

          test "responds with javascript" do
            post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
            assert_response :created
            assert_match /text\/javascript/, response.content_type
            assert_match /category_#{Category.last.id}/, response.body
          end

          describe "when the title is too long" do
            test "does not create a new category" do
              assert_no_difference 'Category.count' do
                post game_categories_path(games(:one), format: :js), params: { category: { title: "This title repeats" * 100 } }
              end
            end

            test "redirects to categories page with message" do
              expected_message = "Title is too long (maximum is 100 characters)"
              post game_categories_path(games(:one), format: :js), params: { category: { title: "This title repeats" * 100 } }
              assert_redirected_to game_categories_path
              assert_equal expected_message, flash[:notice]
            end
          end

          describe "when the title is too short" do
            test "does not create a new category" do
              assert_no_difference 'Category.count' do
                post game_categories_path(games(:one), format: :js), params: { category: { title: "A" } }
              end
            end

            test "redirects to categories page with message" do
              expected_message = "Title is too short (minimum is 2 characters)"
              post game_categories_path(games(:one), format: :js), params: { category: { title: "A" } }
              assert_redirected_to game_categories_path
              assert_equal expected_message, flash[:notice]
            end
          end
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "does not update the category" do
        assert_no_changes -> { Category.find(categories(:one).id).title } do
          patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
        end
      end

      test "responds with 401" do
        patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
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

        test "does not update the category" do
          assert_no_changes -> { Category.find(categories(:one).id).title } do
            patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "does updates the category" do
          assert_changes -> { Category.find(categories(:one).id).title } do
            patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
          end
        end

        test "redirects to category edit page with message" do
          patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This category needs an update" } }
          assert_redirected_to edit_game_category_path
          assert_equal "Category saved!", flash[:success]
        end

        describe "when the title is too long" do
          test "does not create a new category" do
            assert_no_difference 'Category.count' do
              patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This title repeats" * 100 } }
            end
          end

          test "redirects to categories page with message" do
            expected_message = "Title is too long (maximum is 100 characters)"
            patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "This title repeats" * 100 } }
            assert_redirected_to edit_game_category_path
            assert_equal expected_message, flash[:notice]
          end
        end

        describe "when the title is too short" do
          test "does not create a new category" do
            assert_no_difference 'Category.count' do
              patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "A" } }
            end
          end

          test "redirects to categories page with message" do
            expected_message = "Title is too short (minimum is 2 characters)"
            patch game_category_path(games(:one), categories(:one), format: :js), params: { category: { title: "A" } }
            assert_redirected_to edit_game_category_path
            assert_equal expected_message, flash[:notice]
          end
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      test "does not destroy the category" do
        assert_no_difference 'Category.count' do
          delete game_category_path(games(:one), categories(:one), format: :js)
        end
      end

      test "responds with 401" do
        delete game_category_path(games(:one), categories(:one), format: :js)
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

        test "does not destroy the category" do
          assert_no_difference 'Category.count' do
            delete game_category_path(games(:one), categories(:one), format: :js)
          end
        end

        test "redirects to games page" do
          expected_message = "You are not allowed to modify that game"
          delete game_category_path(games(:one), categories(:one), format: :js)
          assert_redirected_to games_path
          assert_equal expected_message, flash[:notice]
        end
      end

      describe "when user has game admin role" do
        test "destroys the category" do
          assert_difference 'Category.count', -1 do
            delete game_category_path(games(:one), categories(:one), format: :js)
          end
        end

        test "responds with javascript" do
          delete game_category_path(games(:one), categories(:one), format: :js)
          assert_response :success
          assert_match /text\/javascript/, response.content_type
          assert_match /.category_#{categories(:one).id}/, response.body
        end

        test "cleans up previous turn record" do
          assert_difference 'Turn.count', -1 do
            post game_categories_path(games(:one), format: :js), params: { category: { title: "Places to visit" } }
          end
        end
      end
    end
  end
end
