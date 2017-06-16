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
    resources :timetables do
      collection do
        get "batch_edit", action: :batch_edit, :as => :batch_edit
        post "batch update", action: :batch_update, :as => :batch_update
      end
    end
  end

  # get "/libraries/:id/timetables/batch_edit", controller: "timetables", action: :batch_edit, :as => :timetables_batch_edit
  # post "/libraries/:id/timetables/batch_update", controller: "timetables", action: :batch_update, :as => :timetables_batch_update


	resource :admin, only: [:show]
end
