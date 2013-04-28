SampleApp::Application.routes.draw do
  resources :users
  resources :sessions, only: [:new, :create, :destroy] #updating a session is nonsense

  root :to => "static_pages#home"

  match '/signup', to: "users#new"
  match '/signin', to: "sessions#new"

  match '/help', to: "static_pages#help"
  match '/about', to: "static_pages#about"
  match '/contact', to: "static_pages#contact"
end
