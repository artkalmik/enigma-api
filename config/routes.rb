Rails.application.routes.draw do
  # API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      # Аутентификация
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/verify_two_factor', to: 'auth#verify_two_factor'
      delete 'auth/logout', to: 'auth#logout'
      
      # Профиль пользователя
      resource :profile, only: [:show, :update] do
        post 'enable_two_factor'
        post 'disable_two_factor'
        post 'verify_two_factor'
      end
      
      # Сообщения
      resources :messages do
        member do
          post 'revoke'
          post 'mark_as_read'
        end
        collection do
          get 'unread'
        end
      end
      
      # Пользователи
      resources :users, only: [:index, :show] do
        collection do
          get 'search'
        end
      end
    end
  end
end
