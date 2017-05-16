Rails.application.routes.draw do
  	devise_for :users, controllers: {sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'}
	resources :libraries
	root to: "libraries#index"
	resource :dashboard, only: [:show]
end
