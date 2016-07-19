Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show] do
        collection do
          post :sign_in
        end
      end
      resources :articles do
        resources :comments
      end
    end
  end
end
