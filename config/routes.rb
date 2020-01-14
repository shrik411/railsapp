Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'widgets#index', as:'home'
  get 'about' => 'pages#about'
  get "users/show" => 'users#new_release', :as => :new_release
  resources :widgets
end
