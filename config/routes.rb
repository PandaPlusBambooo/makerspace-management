Rails.application.routes.draw do
  devise_for :users

  # landing page
  root 'home#index'

  resources :users do
    get :coaches, on: :collection
    get :password, on: :member
    patch :update_password, on: :member
    resources :user_trainings, only: [:new, :create, :destroy]
  end

  resources :trainings

  # checkin related routes
  get '/checkin', to: 'checkin#index'
  get '/checkin/first_time', to: 'checkin#first_time'
  post '/checkin', to: 'checkin#checkin'
end
