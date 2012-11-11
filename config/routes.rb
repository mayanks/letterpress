LetterPress::Application.routes.draw do

  resources :games, :only => [:index, :show, :new, :update, :destroy]
  get "/letterpress", :to => "games#letterpress"
  get "/howtoplay", :to => "games#howtoplay"
  get "/contact", :to => "games#contact"
  root :to => "games#index"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  #resources :users
end
