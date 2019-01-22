Rails.application.routes.draw do
  devise_for :users

  # landing page
  root 'home#index'

  resources :users do
    get :coaches, on: :collection
    get :metrics, on: :collection
    get :password, on: :member
    patch :update_password, on: :member
    resources :user_trainings, only: [:new, :create, :destroy]
    resources :user_signups
  end

  resources :trainings

  resources :signups

  resources :daily_reports

  resources :events

  # checkin related routes
  get '/checkin', to: 'checkin#index'
  get '/checkin/first_time', to: 'checkin#first_time'
  post '/checkin', to: 'checkin#checkin'
  post '/slack/checkin', to: 'slack#checkin'
  post '/slack/checkout', to: 'slack#checkout'
  post '/checkin/checkout_all', to: 'checkin#checkout_all'

  # signup related routes
  post '/signups/dropsignup', to: 'signups#dropsignup'
  # post '/user_signups/drop_signup', to: 'user_signups#drop_signup'

  # misc. static slack routes
  get '/slack/auth', to: 'slack#auth'
  post '/slack/buttons', to: 'slack#buttons'
  post '/slack/events', to: 'slack#events'
end
