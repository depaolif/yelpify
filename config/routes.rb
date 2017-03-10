Rails.application.routes.draw do
  resources :songs, only: [:create,:show] do
    resources :reviews
  end

  resources :registrations, only: [:new,:create]
  resources :sessions, only: [:new,:create]
  get '/login', to: 'sessions#new', as: 'login'
  delete 'sessions/delete', to: 'sessions#destroy', as: 'session'
  get '/home', to: 'application#home', as: 'home'
  post '/search', to: 'spotify_api#search'

  get '/myprofile', to: 'profiles#index'
  get '/profile/edit', to: 'profiles#edit'
  get '/profile/:id', to: 'profiles#show', as: 'show_profile'
  patch '/profile/:id', to: "profiles#update"

  delete '/songs/:song_id/reviews/:id', to: 'reviews#destroy', as: 'destroy_song_review'

  root 'application#home'
end
