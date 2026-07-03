Roadmap Atualizado — PetVet

Rails + Devise + JWT + TDD (RSpec/Capybara) + Segurança

Arquitetura do sistema

O sistema é híbrido:


Web → views Rails com Devise (login tradicional, sessão)
API → endpoints JSON com JWT (para consumo externo, mobile, integrações)


petvet/
├── Web (views Rails)
│     └── Autenticação via Devise (sessão)
│
└── API (namespace /api/v1)
      └── Autenticação via JWT (token)


Stack de tecnologias

CategoriaTecnologiaFrameworkRuby on Rails 8Banco de dadosSQLite (dev) → PostgreSQL (produção)Autenticação webDeviseAutenticação APIdevise-jwt + JWTRevogação de tokensJwtDenylist (Denylist strategy)TestesRSpec + Capybara + FactoryBot + Faker + Shoulda MatchersAutorizaçãoPundit (a instalar na Fase 5)Upload de arquivosActive StoragePaginaçãoKaminariSoft deleteacts_as_paranoid (a instalar na Fase 4)


Fases do projeto


✅ Fase 0 — Ambiente e ferramentas


 Ruby 3.4.4, Rails 8.0.5, Git configurados
 Projeto criado com rails new petvet -d sqlite3 -T
 RSpec, FactoryBot, Faker, Capybara, Shoulda Matchers instalados
 Primeiro commit no GitHub



🔄 Fase 1 — Planejamento do domínio


 Entidades definidas (Usuário, Tutor, Pet, Consulta, Vacina, Peso, Exame, Agendamento, Contrato)
 Relacionamentos mapeados
 Papéis de acesso definidos (Admin / Veterinário / Atendente)
 Decisões de segurança documentadas



🔄 Fase 2 — Autenticação (Devise + JWT)

O que fazer:


Remover autenticação nativa do Rails 8
Instalar Devise + devise-jwt
Configurar User model com roles e soft delete
Criar JwtDenylist (revogação de tokens)
Estruturar rotas web e API separadamente
Escrever testes RSpec cobrindo:

Validações do model User
Login web (Capybara — caminho feliz + caminho triste)
Login API (request spec com JWT)
Logout (token vai pra denylist)
Acesso negado sem token





Gems:

rubygem "devise"
gem "devise-jwt"
gem "jwt"

Estrutura de rotas:

Web:
  GET  /login        → sessão web
  POST /login        → autenticação web
  DELETE /logout     → encerrar sessão

API:
  POST /api/v1/users/sign_in   → retorna JWT
  DELETE /api/v1/users/sign_out → revoga JWT


Fase 3 — Autorização (Pundit)

O que fazer:


Instalar Pundit
Criar policies para cada entidade (quem pode fazer o quê)
Testar autorização via RSpec:

Admin pode tudo
Veterinário pode criar/editar consultas, vacinas, receituários
Atendente não pode acessar prontuário, receituário
Usuário inativo não pode logar





Gem:

rubygem "pundit"

Por quê Pundit e não CanCanCan:
Pundit usa um arquivo de "policy" por model — mais organizado, mais testável, mais explícito. Cada policy é uma classe Ruby simples, fácil de testar com RSpec isoladamente.


Fase 4 — Tutor (com soft delete)

O que fazer:


Instalar acts_as_paranoid (soft delete)
Criar model, migration, controller web e controller API
Testes:

Model: validações (nome, email, cpf únicos)
System: cadastrar, editar, inativar tutor (web)
Request: CRUD via API com JWT



Busca e filtros (nome, cidade, status)
Paginação com Kaminari


Gem:

rubygem "acts_as_paranoid"
gem "kaminari"

Rotas:

Web:  resources :tutores
API:  /api/v1/tutores (index, show, create, update — sem destroy)


Fase 5 — Pet (vinculado ao Tutor)

O que fazer:


Model Pet com belongs_to :tutor
Controller web (nested em tutor: /tutores/:id/pets)
Controller API
Upload de foto do pet (Active Storage)
Testes:

Model: validações + relacionamento
System: cadastrar pet, vincular a tutor, upload de foto
Request: API com JWT
Segurança: tutor_id não pode vir do formulário (strong params)






Fase 6 — Consulta / Prontuário

O que fazer:


Model Consulta (belongs_to :pet, belongs_to :user)
Apenas veterinário cria/edita (Pundit policy)
Testes:

Veterinário pode criar → passa
Atendente tenta criar → bloqueado
System: fluxo completo de consulta
Request: API com JWT






Fase 7 — Receituário / Prescrição

O que fazer:


Model Receituario (belongs_to :consulta, belongs_to :user)
Apenas veterinário (Pundit policy)
Testes de autorização + fluxo



Fase 8 — Vacina

O que fazer:


Model Vacina com validação de data (não pode ser futura)
Apenas veterinário cadastra
Alertas de próxima dose
Testes:

Validação de data futura → deve falhar
Veterinário cadastra → passa
Atendente tenta → bloqueado






Fase 9 — Peso (histórico)

O que fazer:


Model Peso (belongs_to :pet)
Qualquer usuário logado pode registrar
Gráfico de evolução de peso (na view)
Testes de model e system



Fase 10 — Exame (com upload)

O que fazer:


Model Exame com Active Storage (PDF/imagem)
Apenas veterinário faz upload
Testes de upload e autorização



Fase 11 — Agendamento

O que fazer:


Model Agendamento (pet + usuário responsável)
Tipos de serviço: consulta, banho, tosa, ofurô
Status: agendado / confirmado / realizado / cancelado
Testes de fluxo completo (system + request)



Fase 12 — Contrato / Plano Mensal

O que fazer:


Model Contrato (belongs_to :tutor)
Status: ativo / cancelado / expirado
Apenas admin e atendente gerenciam
Testes de autorização + fluxo



Fase 13 — Dashboard

O que fazer:


Controller Dashboard (somente leitura)
Métricas: total de tutores, pets ativos, vacinas a vencer, agendamentos do dia
Testes: cada métrica retorna o valor correto



Fase 14 — Segurança (revisão dedicada)

O que fazer:


SQL Injection → confirmar que ActiveRecord protege todas as queries
XSS → confirmar que views usam <%= %> (escapado)
CSRF → confirmar protect_from_forgery ativo nas rotas web
Mass assignment → revisar strong params de todos os controllers
JWT → confirmar expiração, denylist e que role não vem no payload manipulável
Brakeman (análise estática de segurança):


bashbundle exec brakeman

Gem:

rubygem "brakeman", require: false


Fase 15 — CI/CD e cobertura de testes

O que fazer:


SimpleCov para medir cobertura
GitHub Actions → rodar RSpec a cada push
Badge de "testes passando" no README


Gems:

rubygem "simplecov", require: false


Fase 16 — README e documentação da API

O que fazer:


README completo: o que é, como rodar, como rodar os testes
Documentação dos endpoints da API (método, rota, autenticação, body, response)
Screenshots do sistema funcionando
Badge de CI



Resumo visual

Fase 0  ✅ Ambiente + RSpec configurados
Fase 1  ✅ Planejamento do domínio
Fase 2  🔄 Devise + JWT (autenticação web + API)
Fase 3     Pundit (autorização por papel)
Fase 4     Tutor (soft delete + Kaminari)
Fase 5     Pet (Active Storage)
Fase 6     Consulta/Prontuário
Fase 7     Receituário
Fase 8     Vacina
Fase 9     Peso
Fase 10    Exame (upload)
Fase 11    Agendamento
Fase 12    Contrato/Plano
Fase 13    Dashboard
Fase 14    Revisão de segurança (Brakeman)
Fase 15    CI/CD + cobertura
Fase 16    README + documentação da API


Tipos de teste que vamos escrever

TipoFerramentaTestaModel specRSpec + ShouldaValidações, relacionamentos, métodosSystem specRSpec + CapybaraFluxo do usuário na interface webRequest specRSpecEndpoints da API (JSON + JWT)Policy specRSpec + PunditAutorização por papel


Convenção de commits

feat:     nova funcionalidade
fix:      correção de bug
test:     adição ou alteração de testes
refactor: melhoria de código sem mudar comportamento
docs:     documentação
security: correção ou melhoria de segurança
chore:    configuração, gems, CI