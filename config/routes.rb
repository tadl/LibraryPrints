Rails.application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  delete '/logout', to: 'sessions#destroy', as: :logout

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: 'portal#home'
  get '/submit', to: 'portal#submit',        as: 'submit_job'
  post '/submit', to: 'portal#create_job'
  get  '/thank_you', to: 'portal#thank_you', as: :thank_you

  get '/dashboard', to: 'portal#dashboard', as: :dashboard
  get '/jobs/:id',   to: 'portal#show',      as: :job

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
