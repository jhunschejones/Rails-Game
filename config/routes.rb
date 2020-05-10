Rails.application.routes.draw do
  root to: "games#index"

  mount ActionCable.server, at: '/cable'

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  resources :users, only: [:show]

  get '/games/:id/play', to: 'games#play', as: :play_game
  post '/user_games/:id/confirm_action_completed', to: 'user_games#confirm_action_completed', as: :confirm_action_completed
  resources :games, except: [:delete, :destroy] do
    resources :users, only: [:index]
    resources :user_games, only: [:edit, :update]
    post '/users', to: 'users#add_to_game', as: :add_user
    delete '/users/:user_id', to: 'users#remove_from_game', as: :remove_user

    resources :categories, except: [:show, :new] do
      resources :options, only: [:create, :destroy]
    end
  end
end
