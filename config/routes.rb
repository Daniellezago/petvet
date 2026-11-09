Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  # ================================
  # DEVISE — SCOPE ÚNICO (:user)
  # ================================
  devise_for :users,
            path: "",
            path_names: {
            sign_in: "login",
            sign_out: "logout"
            }

  get "dashboard/index"
  root to: "dashboard#index"

  # =========================================
  # PERFIL E AUTENTICAÇÃO DOIS FATORES (2FA)
  # =========================================
  get    "perfil", to: "perfil#show", as: "perfil"

  get    "dois_fatores/novo",              to: "dois_fatores#new",               as: "novo_dois_fatores"
  post   "dois_fatores",                   to: "dois_fatores#create",            as: "dois_fatores"
  delete "dois_fatores",                   to: "dois_fatores#destroy"
  get    "dois_fatores/codigos_backup",    to: "dois_fatores#codigos_backup",    as: "codigos_backup_dois_fatores"
  post   "dois_fatores/backup_codes/gerar", to: "dois_fatores#gerar_backup_codes", as: "gerar_backup_codes_dois_fatores"

  # ========================================
  # RECURSOS WEB
  # ========================================

  resources :tutores do
    member do
      patch :reativar
    end
  end

  resources :veterinarios do
    member do
      patch :reativar
    end
  end

  resources :usuarios, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :pets, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :pesos, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :consultas, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :vacinas, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :exames, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :agendamentos
  resources :contratos

  # =======================================================
  # ROTAS API (JWT) — reaproveitam o scope :user do Devise
  # =======================================================
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
      resources :tutores, only: [ :index, :show, :create, :update, :destroy ]
      # Pet NUNCA deve ter rota de destroy - histórico médico é permanente
      resources :pets, only: [ :index, :show, :create, :update ]
      resources :pesos, only: [ :index, :show, :create, :update ]
      resources :consultas, only: [ :index, :show, :create, :update ]
      resources :vacinas, only: [ :index, :show, :create, :update ]
      resources :agendamentos, only: [ :index, :show, :create, :update, :destroy ]
      resources :exames, only: [ :index, :show, :create, :update ]
      resources :receituarios, only: [ :index, :show, :create, :update ]
      resources :contratos, only: [ :index, :show, :create, :update, :destroy ]
    end
  end
end
