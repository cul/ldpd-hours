Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "locations#index"

  resources :users
  # devise_for :users, controllers: {sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  resources :locations, param: :code do
    get :open_now, on: :collection

    resources :timetables, only: [] do
      collection do
        get :exceptional_edit
        get :batch_edit
        post :batch_update
      end
    end
  end

  resource :admin, only: [:show]

  get 'api/v1/locations/open_now' => 'api/v1/locations#open_now'
  get 'api/v1/locations/:code' => 'api/v1/locations#open_hours'
end
