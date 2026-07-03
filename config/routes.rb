Rails.application.routes.draw do
  # ================================
  # ROTAS WEB (com views Rails)
  # ================================
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout"
             }

  root to: "dashboard#index"

  resources :tutores
  resources :pets
  resources :consultas
  resources :vacinas
  resources :agendamentos
  resources :contratos

  # ================================
  # ROTAS API (JWT)
  # ================================
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 controllers: {
                   sessions: "api/v1/users/sessions",
                   registrations: "api/v1/users/registrations"
                 }

      resources :tutores, only: [:index, :show, :create, :update]
      resources :pets, only: [:index, :show, :create, :update]
      resources :consultas, only: [:index, :show, :create, :update]
      resources :vacinas, only: [:index, :show, :create, :update]
      resources :agendamentos, only: [:index, :show, :create, :update]
    end
  end
end