Rails.application.routes.draw do
  namespace :api do
    resources :tasks, only: [] do
      resource :status, only: [:show, :update], controller: 'tasks/statuses'
      resource :priority, only: [:show, :update], controller: 'tasks/priorities'
    end
  end
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  namespace :admin do
    resources :users
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'tasks#index'
  resources :tasks do
    post :confirm, action: :confirm_new, on: :new
    post :import, on: :collection
  end
end
