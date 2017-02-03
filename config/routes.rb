Rails.application.routes.draw do

  resources :projects

  # Root
  root :to => 'projects#landing'

  # Specific Projects
  get '/planocore', to: 'projects#planocore'
  get '/planoadmin', to: 'projects#planoadmin'
end
