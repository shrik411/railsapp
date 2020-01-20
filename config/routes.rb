Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'widgets#listall', as:'home'
  get 'about' => 'pages#about'
  get "users/show" => 'users#new_release1', :as => :new_release1
  get "users/new_release" => 'users#new_release', :as => :new_release
  post "users/login" => 'users#login', :as => :login
  get "users/logout" => 'users#destroy', :as => :logout
  get "users/details" => 'users#details', :as => :userdetails
  get "widgets/search" => 'widgets#search', :as => :searchwidgets
  resources :widgets
  resources :users
end
