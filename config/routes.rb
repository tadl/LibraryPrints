Rails.application.routes.draw do
  # OmniAuth callback for external providers (login)
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]

  # Sign out route
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Admin interface (RailsAdmin)
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Public home page
  root to: 'portal#home'

  # 3D print request submission
  # GET  /submit        → show the webform
  # POST /submit        → process the form and create a print job
  get  '/submit', to: 'portal#submit',      as: :submit_job
  post '/submit', to: 'portal#create_job'
  # Confirmation page after submitting
  get  '/thank_you', to: 'portal#thank_you', as: :thank_you

  # Magic-link token requests
  # GET  /token_request     → show form where patron enters their email
  # POST /token_request     → send them a magic-link email
  get  '/token_request', to: 'portal#token_request', as: :token_request
  post '/token_request', to: 'portal#create_token_request'
  # Confirmation page after requesting a magic link
  get  '/token_thank_you', to: 'portal#token_thank_you', as: :token_thank_you

  # Patron dashboard & job details (requires token)
  # GET /dashboard?token=…  → list all of a patron’s jobs
  get '/dashboard', to: 'portal#dashboard', as: :dashboard
  # GET /jobs/:id?token=…   → details for a single print job
  get '/jobs/:id', to: 'portal#show', as: :job

  # Health check endpoint for load-balancers / uptime monitors
  # Returns 200 OK if the app boots without errors, otherwise 500.
  get '/up', to: 'rails/health#show', as: :rails_health_check

  # You can uncomment / modify this if you add other top-level resources later
  # root "posts#index"
end
