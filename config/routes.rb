Rails.application.routes.draw do
  get "dashboard/index"
  get "tutores/index"
  get "tutores/show"
  get "tutores/new"
  get "tutores/edit"

  # ================================
  # DEVISE — SCOPE ÚNICO (:user)
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
  # ROTAS API (JWT) — reaproveitam o scope :user do Devise
  # ================================
  devise_scope :user do
    namespace :api do
      namespace :v1 do
        post   "users/sign_in",  to: "users/sessions#create"
        delete "users/sign_out", to: "users/sessions#destroy"
        post   "users",          to: "users/registrations#create"
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tutores, only: [ :index, :show, :create, :update, :destroy]
      resources :pets, only: [ :index, :show, :create, :update ]
      resources :consultas, only: [ :index, :show, :create, :update ]
      resources :vacinas, only: [ :index, :show, :create, :update ]
      resources :agendamentos, only: [ :index, :show, :create, :update ]
    end
  end
end