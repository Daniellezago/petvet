# 🐾 PetVet

Sistema de gestão veterinária desenvolvido em Ruby on Rails, com API REST autenticada via JWT e interface web com Devise. Inspirado em sistemas como o PetSys, construído do zero com foco em **TDD**, **segurança** e **boas práticas de arquitetura**.

> ⚠️ **Projeto em desenvolvimento.** O backend/API está em construção ativa e coberto por testes automatizados. As telas web (views) ainda estão por vir — o foco atual é consolidar o domínio e a API antes de construir a interface.

---

## 🧱 Stack

- **Ruby** 3.4.4 / **Rails** 8.0.5
- **Banco de dados:** SQLite (desenvolvimento)
- **Autenticação web:** Devise
- **Autenticação API:** Devise + JWT (`devise-jwt`)
- **Autorização:** Pundit (controle de acesso por papéis)
- **Testes:** RSpec, Capybara, FactoryBot, Faker, Shoulda Matchers, Pundit Matchers
- **Paginação:** Kaminari

---

## 👥 Papéis de usuário

O sistema possui três papéis distintos, cada um com permissões específicas via Pundit:

- **Admin** — acesso completo, incluindo inativação de cadastros
- **Veterinário** — acesso operacional ao dia a dia clínico
- **Atendente** — acesso operacional, sem permissões administrativas

---

## ✅ Funcionalidades implementadas

### Autenticação e autorização
- Login via Devise (web) e JWT (API), com revogação de token (denylist)
- Senhas fortes obrigatórias (mínimo 8 caracteres, com maiúscula, minúscula, número e caractere especial)
- Controle de acesso por papel de usuário via Pundit

### Tutor (cliente)
- CRUD completo via API (`index`, `show`, `create`, `update`, `destroy`)
- **Soft delete real:** tutores são inativados (`ativo: false`), nunca removidos do banco
- **Unicidade escopada:** CPF e e-mail só bloqueiam novos cadastros se o registro duplicado estiver **ativo** — permitindo recadastro caso o antigo tenha sido inativado
- Apenas administradores podem inativar um tutor

### Pet
- CRUD via API (`index`, `show`, `create`, `update`)
- Vinculado a um Tutor (`belongs_to`)
- **Nunca pode ser removido, em nenhuma hipótese** — histórico médico é permanente, tanto por proteção legal da clínica quanto para o tutor ter acesso ao histórico completo do animal. Essa regra é garantida em três camadas independentes:
  1. A rota de `destroy` nunca é exposta na API
  2. A policy (`PetPolicy#destroy?`) sempre nega a autorização
  3. O próprio model bloqueia `destroy`/`destroy!` via callback, mesmo se chamado diretamente (ex: console Rails)
- Reatribuição de tutor bloqueada em updates: `tutor_id` só é aceito na criação do pet, nunca em uma edição posterior — evita que um pet seja "transferido" de tutor sem controle

---

## 🧪 Testes

O projeto segue **TDD** com cobertura crescente via RSpec.

```bash
bundle exec rspec
```

Estado atual: **84 exemplos, 0 falhas** (7 pendências são apenas placeholders de views/helpers ainda não implementados).

Principais suítes:
- `spec/models` — validações, associações, regras de negócio
- `spec/policies` — regras de autorização por papel
- `spec/requests/api/v1` — comportamento da API ponta a ponta (autenticação, permissões, status HTTP)

---

## 🚀 Rodando localmente

```bash
# Clonar o repositório
git clone https://github.com/Daniellezago/petvet
cd petvet

# Instalar dependências
bundle install

# Preparar o banco de dados
bin/rails db:create db:migrate

# Rodar os testes
bundle exec rspec

# Subir o servidor
bin/rails s
```

> As rotas da API estão disponíveis em `/api/v1/...` (ex: `POST /api/v1/users/sign_in` para login). As views web ainda estão em construção.

---

## 🗺️ Roadmap

- [ ] Model Consulta, Vacina, Exame e Receituário (histórico médico, também com proteção contra remoção)
- [ ] Model Agendamento e Contrato/Plano
- [ ] Migração de `role` (User), `sexo` (Pet) e `status` (Agendamento) para enums nativos do Rails
- [ ] Upload de exames via Active Storage, com validação estrita de Content-Type (PDF, JPEG, PNG)
- [ ] Auditoria automática: `usuario_id` de consultas/vacinas/exames sempre injetado a partir do usuário autenticado, nunca aceito via formulário
- [ ] Construção das views web (interface visual)
- [ ] Containerização com Docker (fase avançada — atualmente o projeto roda localmente via asdf)

---

## 📌 Decisões técnicas de destaque

- **Soft delete com unicidade escopada:** em vez de bloquear permanentemente CPF/e-mail já usados, a validação de unicidade considera apenas registros ativos — resolvendo um problema comum em sistemas de cadastro com histórico.
- **Proteção em camadas (defense in depth):** a regra "Pet nunca é removido" não depende de um único ponto de falha — está garantida na rota, na policy e no model, então mesmo um erro de código em uma camada não quebra a garantia.
- **Separação de parâmetros por ação:** `tutor_id` é permitido apenas no `create` de Pet, nunca no `update`, evitando reatribuições não auditadas.

