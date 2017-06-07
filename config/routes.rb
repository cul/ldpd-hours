Rails.application.routes.draw do
  	devise_for :users, controllers: {sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'}
  	root to: "libraries#index"

  	namespace :admin do
  		resources :users
  	end
  	
  	devise_scope :user do
  	  get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
  	  get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
  	end

	resources :libraries 

  get "/libraries/:id/time_tables/batch_edit", controller: "time_tables", action: :batch_edit, :as => :time_tables_batch_edit
  post "/libraries/:id/time_tables/batch_update", controller: "time_tables", action: :batch_update, :as => :time_tables_batch_update

	resource :admin, only: [:show]
end
