Rails.application.routes.draw do
  root to: "locations#index"

  resources :users
  devise_for :users, controllers: {sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  resources :locations do
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
end
