Rails.application.routes.draw do
  get 'calendar/show'

  	devise_for :users, controllers: {sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'}
  	
  	namespace :admin do
  		resources :users
  	end
  	
  	devise_scope :user do
	  get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
	  get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
	end

	resources :libraries
	root to: "libraries#index"
	resource :admin, only: [:show]

  resource :calendar, only: [:show], controller: :calendar
end
