Rails.application.routes.draw do
  	devise_for :users
	resources :libraries
	root to: "libraries#index"
end
