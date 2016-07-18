Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show, :update, :destroy]
      resources :articles, only: [:index, :create, :show, :update, :destroy]
    end
  end
end
