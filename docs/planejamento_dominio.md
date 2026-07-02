# Planejamento do Domínio — PetVet

## Entidades e Relacionamentos

```
Usuário (Admin / Veterinário / Atendente)
│
Tutor (Cliente)
│
└── Pet
      ├── Consulta
      │     └── Receituário (Prescrição)
      ├── Vacina
      ├── Peso (histórico)
      └── Exame (upload de arquivo)

Agenda (Agendamento)
└── vinculada a Pet + Usuário (veterinário/atendente responsável)

Contrato/Plano
└── vinculado a Tutor
```

---

## Tabela de Entidades e Campos

### Usuário
| Campo | Tipo | Observação |
|---|---|---|
| nome | string | |
| email | string | único, obrigatório |
| password | string | armazenado com hash |
| role | string | admin / veterinario / atendente |
| ativo | boolean | soft delete |

### Tutor (Cliente)
| Campo | Tipo | Observação |
|---|---|---|
| nome | string | obrigatório |
| email | string | único |
| telefone | string | |
| cpf | string | único |
| endereco | string | |
| ativo | boolean | soft delete — nunca apagar |

### Pet
| Campo | Tipo | Observação |
|---|---|---|
| nome | string | obrigatório |
| especie | string | cão, gato, etc |
| raca | string | |
| data_nascimento | date | |
| sexo | string | macho / fêmea |
| cor | string | |
| ativo | boolean | soft delete |
| tutor_id | references | obrigatório |

### Consulta
| Campo | Tipo | Observação |
|---|---|---|
| data | datetime | obrigatório |
| motivo | text | |
| diagnostico | text | só veterinário edita |
| tratamento | text | |
| observacoes | text | |
| pet_id | references | obrigatório |
| usuario_id | references | veterinário responsável |

### Receituário (Prescrição)
| Campo | Tipo | Observação |
|---|---|---|
| medicamento | string | |
| dosagem | string | |
| instrucoes | text | |
| data_emissao | date | |
| consulta_id | references | |
| usuario_id | references | veterinário |

### Vacina
| Campo | Tipo | Observação |
|---|---|---|
| nome | string | obrigatório |
| data_aplicacao | date | não pode ser no futuro |
| proxima_dose | date | |
| lote | string | |
| fabricante | string | |
| pet_id | references | |
| usuario_id | references | veterinário que aplicou |

### Peso
| Campo | Tipo | Observação |
|---|---|---|
| valor | decimal | em kg |
| data_medicao | date | |
| observacao | string | |
| pet_id | references | |

### Exame
| Campo | Tipo | Observação |
|---|---|---|
| tipo | string | sangue, raio-x, etc |
| data | date | |
| descricao | text | |
| arquivo | Active Storage | upload de PDF/imagem |
| pet_id | references | |
| usuario_id | references | |

### Agendamento
| Campo | Tipo | Observação |
|---|---|---|
| data_hora | datetime | obrigatório |
| tipo_servico | string | consulta / banho / tosa / ofurô |
| status | string | agendado / confirmado / realizado / cancelado |
| observacoes | text | |
| pet_id | references | |
| usuario_id | references | responsável |

### Contrato/Plano
| Campo | Tipo | Observação |
|---|---|---|
| nome_plano | string | ex: Plano Mensal Banho |
| descricao | text | |
| valor | decimal | |
| data_inicio | date | |
| data_fim | date | |
| status | string | ativo / cancelado / expirado |
| tutor_id | references | |

---

## Papéis de Acesso (Authorization)

| Ação | Admin | Veterinário | Atendente |
|---|---|---|---|
| Cadastrar/Editar Tutor | ✅ | ✅ | ✅ |
| Inativar Tutor (soft delete) | ✅ | ❌ | ❌ |
| Cadastrar/Editar Pet | ✅ | ✅ | ✅ |
| Ver Consultas | ✅ | ✅ | ✅ |
| Criar/Editar Consulta | ✅ | ✅ | ❌ |
| Apagar Consulta | ✅ | ❌ | ❌ |
| Cadastrar Vacina | ✅ | ✅ | ❌ |
| Registrar Peso | ✅ | ✅ | ✅ |
| Receituário/Prescrição | ✅ | ✅ | ❌ |
| Upload de Exames | ✅ | ✅ | ❌ |
| Gerenciar Agendamentos | ✅ | ✅ | ✅ |
| Cancelar Agendamento | ✅ | ✅ | ✅ |
| Gerenciar Contratos/Planos | ✅ | ❌ | ✅ |
| Gerenciar Usuários | ✅ | ❌ | ❌ |
| Ver Dashboard | ✅ | ✅ | ✅ |

---

## Ordem de construção (por dependência)

```
1. Usuário (autenticação + roles)
2. Tutor
3. Pet (depends on: Tutor)
4. Consulta (depends on: Pet, Usuário)
5. Receituário (depends on: Consulta, Usuário)
6. Vacina (depends on: Pet, Usuário)
7. Peso (depends on: Pet)
8. Exame (depends on: Pet, Usuário)
9. Agendamento (depends on: Pet, Usuário)
10. Contrato/Plano (depends on: Tutor)
11. Dashboard (depende de tudo)
```

---

## Decisões de segurança

- **Soft delete** em Tutor e Usuário — nunca apagar, só inativar
- **Strong parameters** em todos os controllers — nunca aceitar `role` ou `ativo` via formulário
- **Autorização por role** em toda action sensível
- **Validação de data** em Vacina (`data_aplicacao` não pode ser futura)
- **Upload seguro** em Exame via Active Storage
- **Senhas** com hash via `has_secure_password`
- **CSRF** proteção ativa (padrão Rails)
