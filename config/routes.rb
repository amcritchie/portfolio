Rails.application.routes.draw do

  resources :projects

  # Root
  root :to => 'projects#index'
end
