LetterPress::Application.routes.draw do

  get "/games/completed", :to => "games#completed"
  resources :games, :only => [:index, :show, :new, :update, :destroy]
  post "/games/:id", :to => "games#show"
  get "/letterpress", :to => "games#letterpress"
  get "/about", :to => "games#about"
  get "/howtoplay", :to => "games#howtoplay"
  get "/contact", :to => "games#contact"
  get "/privacy", :to => "games#privacy"
  get "/tos", :to => "games#tos"
  get "/leaderboard", :to => "home#leaderboard"
  get "/stats", :to => "home#stats"
  get "/home", :to => "home#index"
  root :to => "games#index"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  #resources :users
end
