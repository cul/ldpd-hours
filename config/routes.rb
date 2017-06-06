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

	resources :libraries do
    resources :calendars, only: [:create]
  end
  get 'libraries/:id/edit_calendar', controller: :libraries, action: :edit_calendar, as: :edit_library_calendar
	resource :admin, only: [:show]
end
