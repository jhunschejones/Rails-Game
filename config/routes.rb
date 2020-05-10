Rails.application.routes.draw do
  root to: "games#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  resources :users, only: [:show]

  get '/games/:id/play', to: 'games#play', as: :play_game
  get '/games/:id/turn_completed', to: 'games#turn_completed', as: :confirm_turn_completed
  resources :games, except: [:delete, :destroy] do
    resources :users, only: [:index]
    post '/users', to: 'users#add_to_game', as: :add_user
    delete '/users/:user_id', to: 'users#remove_from_game', as: :remove_user

    resources :categories, except: [:show, :new] do
      resources :options, only: [:create, :destroy]
    end
  end
end
