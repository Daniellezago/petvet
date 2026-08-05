# 🐾 PetVet

Sistema de gestão veterinária desenvolvido em Ruby on Rails, com API REST autenticada via JWT, documentação interativa (Swagger/OpenAPI) e interface web em Tailwind CSS + Hotwire. Inspirado em sistemas como o PetSys, construído do zero com foco em **TDD**, **segurança** e **boas práticas de arquitetura**.

> 🚧 **Projeto em desenvolvimento ativo.** Backend e API estão **completos** para as 9 entidades do domínio, com documentação interativa e CI/CD funcionando. Estamos agora na fase de construção das **views web**, seguindo a ordem do menu lateral: Tutores concluído, Pets/Peso/Consulta/Vacina/Exame/Usuários já com tela — restam Receituário, Agendamento, Contrato, Veterinário e os módulos de Procedimentos/Financeiro.

---

## 🧱 Stack

- **Ruby** 3.4.4 / **Rails** 8.0.5
- **Banco de dados:** SQLite (desenvolvimento)
- **Frontend:** Tailwind CSS, Hotwire (Turbo + Stimulus), Lucide Icons
- **Gráficos:** Chartkick + Groupdate
- **Autenticação web:** Devise
- **Autenticação API:** Devise + JWT (`devise-jwt`)
- **Autorização:** Pundit (controle de acesso por papéis)
- **Upload de arquivos:** Active Storage
- **Documentação de API:** Swagger/OpenAPI via rswag (interativa, em `/api-docs`)
- **Testes:** RSpec, Capybara, FactoryBot, Faker, Shoulda Matchers, Pundit Matchers
- **Paginação:** Kaminari
- **CI/CD:** GitHub Actions (Rubocop, Brakeman, RSpec a cada push)

---

## 👥 Papéis de usuário

- **Admin** — acesso completo, incluindo inativação de cadastros e gestão de usuários
- **Veterinário** — acesso operacional ao dia a dia clínico, precisa de CRMV cadastrado para emitir receituários
- **Atendente** — acesso operacional, sem permissões administrativas

---

## ✅ Backend/API — 100% completo (9 entidades)

Todas as entidades abaixo têm model, migration, policy, controller de API, rotas, testes de model e testes de request, além de documentação Swagger interativa.

### Autenticação e autorização
- Login via Devise (web) e JWT (API), com revogação de token (denylist)
- Senhas fortes obrigatórias
- Controle de acesso por papel via Pundit

### Tutor
- Soft delete real (`ativo: false`, nunca removido do banco)
- Unicidade de CPF/e-mail escopada a registros ativos (recadastro permitido se o antigo estiver inativo)

### Pet
- Campos: espécie, raça, sexo, porte, cor, castrado, peso atual, idade calculada automaticamente (anos/meses) a partir da data de nascimento
- **Nunca pode ser removido** — proteção em três camadas (rota, policy, model)
- `tutor_id` só é aceito na criação, nunca em updates

### Peso
- Histórico de pesagens por pet (data + valor) — entidade resgatada do escopo original que havia ficado de fora
- Mesma proteção contra remoção das entidades de histórico médico

### Consulta, Vacina, Exame, Receituário
- Vacina tem campo `categoria` (Vacina / Antiparasitário)
- Auditoria automática e testada: `usuario_id` sempre vem do usuário autenticado, nunca do formulário
- Exame aceita upload de laudo (PDF/JPEG/PNG) via Active Storage, com validação de tipo de arquivo (inclusive teste simulando upload malicioso disfarçado)
- Receituário exige CRMV do usuário responsável, copiado automaticamente no momento da emissão (auditoria dupla: usuário + CRMV)
- Histórico médico permanente — nunca removido, em três camadas de proteção

### Agendamento
- Tipos: consulta, exame, cirurgia, banho, tosa
- Campo `veterinario_id` (opcional por enquanto) — base para a futura "Minha Agenda" por profissional
- Validação cruzada: o pet informado deve pertencer ao tutor informado
- Diferente das entidades de histórico médico, pode ser removido de verdade (restrito a admin)

### Contrato/Plano
- Tipos: particular ou convênio
- Campos de convênio (nome, carteirinha, percentual de cobertura) obrigatórios apenas quando `tipo_contrato == convenio`
- Um tutor pode ter múltiplos contratos, um por pet — reflete cenário real de convênios com carteirinha individual por animal, mesmo sob o mesmo titular

### Veterinário (model criado, sem controller/views ainda)
- Perfil profissional separado do `User` de login: nome, CRMV, especialidade, cor de identificação na agenda
- `belongs_to :user` — a conta de login continua sendo o `User`; o `Veterinario` guarda os dados profissionais

---

## 🎨 Frontend/Views — em construção

### Já implementado
- **Layout geral:** sidebar verde-esmeralda com 7 seções colapsáveis, topbar com usuário logado, mensagens flash
- **Login** estilizado
- **Dashboard:** cards de métricas, gráfico de área (crescimento com filtro de período: 30 dias/6 meses/1 ano), gráfico donut de pets por raça com legenda detalhada, gráfico de barras Top 5 raças
- **Tutores:** listagem com busca (nome/email/CPF), filtro de ativos/inativos, ícones de ação rápida (WhatsApp, e-mail, endereço no Google Maps), CPF/telefone mascarados na listagem (LGPD), CRUD completo
- **Pets:** CRUD completo com todos os campos (incluindo porte, cor, castrado, idade calculada)
- **Pesos:** CRUD completo
- **Consultas, Vacinas, Exames:** CRUD completo (Exame com upload de arquivo funcionando via `multipart: true`)
- **Usuários:** CRUD completo, restrito a admin (seção Sistema)

### Sidebar — estrutura completa (itens sem tela marcados como "em breve" na própria interface)
1. **Dashboard** ✅
2. **Cadastros** — Tutores ✅, Pets ✅, Veterinários 🔲, Usuários ✅, Procedimentos 🔲
3. **Atendimento** — Agendamento Geral (rota existe, view não) 🔲, Agendas por setor (consulta/exame/cirurgia/vacina/estética/hospedagem/internação) 🔲
4. **Veterinário** — Minha Agenda 🔲, Consultas ✅, Prontuário 🔲, Vacinas Aplicadas ✅, Receituário (backend pronto, view não) 🔲, Histórico 🔲
5. **Procedimentos Médicos** — Exames ✅, Cirurgias 🔲, Internação 🔲
6. **Financeiro** — Faturamento 🔲, Contas a Pagar 🔲, Contas a Receber 🔲, Contratos (backend pronto, view não) 🔲
7. **Sistema** — Configurações 🔲 (restrito a admin)

---

## 🧪 Testes

```bash
bundle exec rspec
```

Estado atual: **300+ exemplos, 0 falhas** (rodar localmente para número exato — cresce a cada view nova que ganha teste).

Principais suítes:
- `spec/models` — validações, associações, regras de negócio
- `spec/policies` — autorização por papel
- `spec/requests/api/v1` — comportamento da API ponta a ponta
- `spec/requests/api/v1/docs` — specs que geram a documentação Swagger automaticamente

---

## 🚀 Rodando localmente

```bash
git clone https://github.com/Daniellezago/petvet
cd petvet
bundle install
bin/rails db:create db:migrate
bundle exec rspec
bin/dev
```

`bin/dev` sobe o servidor Rails **e** o compilador do Tailwind simultaneamente. API em `/api/v1/...`, documentação interativa em `/api-docs`.

---

## 🗺️ Roadmap

### ✅ Backend/API — concluído
- 9 entidades completas com model, policy, controller, testes e documentação Swagger
- Enums nativos em todos os campos categóricos (sem dívida técnica)
- Upload de arquivos, paginação, CI/CD, formato de erro padronizado

### 🔨 Frontend — próximos passos, na ordem do menu
1. **Cadastros → Veterinários:** controller, policy, views (CRUD completo) — depois, tornar `veterinario_id` obrigatório em Agendamento
2. **Cadastros → Procedimentos:** novo model `Procedimento` (nome, categoria, **valor**) — catálogo de serviços, base do futuro Faturamento
3. **Atendimento → Agendamento Geral:** view web (model/controller de API já existem)
4. **Atendimento → Agendas por setor:** telas filtradas por `tipo_agendamento`
5. **Veterinário → Minha Agenda:** agendamentos filtrados pelo `veterinario_id` do usuário logado
6. **Veterinário → Receituário:** view web (backend 100% pronto, só falta a tela)
7. **Veterinário → Prontuário, Histórico:** views agregando dados de Consulta/Vacina/Exame/Receituário por pet
8. **Procedimentos Médicos → Cirurgias, Internação:** novo model `Internacao` (ocupação de leito por período, diferente de agendamento por horário)
9. **Financeiro:** Contratos precisa de view web; Contas a Pagar/Receber e Faturamento são models novos

### 📌 Funcionalidades transversais pendentes
- Botão "Imprimir" em Exames e Receituários (`window.print()` + CSS `@media print`)
- "Esqueci minha senha" (base do Devise `:recoverable` já existe)
- Confirmação de e-mail no cadastro (`:confirmable`)
- Containerização com Docker

### 🔭 Expansões futuras (pós-v1)
- Integração de pagamentos
- Portal do cliente (Tutor acessa os próprios dados)
- Notificações automáticas de agendamento
- Hospedagem/Day Care

---

## 📌 Decisões técnicas de destaque

- **Soft delete com unicidade escopada:** validação de unicidade de CPF/e-mail considera apenas registros ativos.
- **Proteção em camadas (defense in depth):** "histórico médico nunca é removido" garantido na rota, na policy e no model simultaneamente.
- **Auditoria real, não decorativa:** `usuario_id` nunca vem do request — testes tentam ativamente burlar essa regra. Receituário tem auditoria dupla (usuário + CRMV).
- **Inflexão de nomes em português:** Rails assume pluralização em inglês por padrão; corrigido com regras customizadas para "Consulta", "Tutor" e outras palavras.
- **Modelagem de convênio baseada em cenário real:** Contrato vinculado a Tutor **e** a um Pet específico, refletindo carteirinha individual por animal mesmo sob o mesmo titular.
- **Veterinário separado de User:** perfil profissional distinto da conta de login.
- **UI documenta o roadmap:** itens do menu sem backend aparecem desabilitados com "(em breve)" em vez de simplesmente não existir.
- **LGPD na listagem de Tutores:** CPF e telefone mascarados na tabela, dado completo só na tela de detalhe.

