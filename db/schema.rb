# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_07_29_235809) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agendamentos", force: :cascade do |t|
    t.datetime "data_hora", null: false
    t.integer "status", default: 0, null: false
    t.text "observacoes"
    t.integer "tutor_id", null: false
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tipo_agendamento", default: 0, null: false
    t.index ["data_hora"], name: "index_agendamentos_on_data_hora"
    t.index ["pet_id"], name: "index_agendamentos_on_pet_id"
    t.index ["tutor_id"], name: "index_agendamentos_on_tutor_id"
    t.index ["usuario_id"], name: "index_agendamentos_on_usuario_id"
  end

  create_table "consultas", force: :cascade do |t|
    t.datetime "data", null: false
    t.text "descricao", null: false
    t.text "diagnostico"
    t.text "tratamento"
    t.text "observacoes"
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_consultas_on_data"
    t.index ["pet_id"], name: "index_consultas_on_pet_id"
    t.index ["usuario_id"], name: "index_consultas_on_usuario_id"
  end

  create_table "contratos", force: :cascade do |t|
    t.integer "tipo_contrato", default: 0, null: false
    t.string "nome_convenio"
    t.string "numero_carteirinha"
    t.decimal "percentual_cobertura", precision: 5, scale: 2
    t.date "data_inicio", null: false
    t.date "data_fim"
    t.integer "tutor_id", null: false
    t.integer "pet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["numero_carteirinha"], name: "index_contratos_on_numero_carteirinha"
    t.index ["pet_id"], name: "index_contratos_on_pet_id"
    t.index ["tutor_id"], name: "index_contratos_on_tutor_id"
  end

  create_table "exames", force: :cascade do |t|
    t.string "tipo_exame", null: false
    t.date "data", null: false
    t.text "resultado"
    t.text "observacoes"
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_exames_on_data"
    t.index ["pet_id"], name: "index_exames_on_pet_id"
    t.index ["usuario_id"], name: "index_exames_on_usuario_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "pesos", force: :cascade do |t|
    t.date "data", null: false
    t.decimal "peso", precision: 5, scale: 2, null: false
    t.text "observacoes"
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_pesos_on_pet_id"
    t.index ["usuario_id"], name: "index_pesos_on_usuario_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string "nome", null: false
    t.string "especie", null: false
    t.string "raca"
    t.integer "sexo", default: 0, null: false
    t.date "data_nascimento"
    t.decimal "peso_atual", precision: 5, scale: 2
    t.integer "tutor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "castrado", default: false, null: false
    t.integer "porte", default: 1, null: false
    t.string "cor"
    t.index ["nome"], name: "index_pets_on_nome"
    t.index ["tutor_id"], name: "index_pets_on_tutor_id"
  end

  create_table "receituarios", force: :cascade do |t|
    t.integer "tipo_receituario", default: 0, null: false
    t.string "medicamento", null: false
    t.text "posologia", null: false
    t.string "duracao_tratamento"
    t.text "observacoes"
    t.string "crmv_responsavel", null: false
    t.date "data_emissao", null: false
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_emissao"], name: "index_receituarios_on_data_emissao"
    t.index ["pet_id"], name: "index_receituarios_on_pet_id"
    t.index ["usuario_id"], name: "index_receituarios_on_usuario_id"
  end

  create_table "tutors", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "telefone"
    t.string "cpf"
    t.string "endereco"
    t.boolean "ativo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo", default: true, null: false
    t.integer "role", default: 2, null: false
    t.string "crmv"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacinas", force: :cascade do |t|
    t.string "nome", null: false
    t.date "data_aplicacao", null: false
    t.date "proxima_dose"
    t.string "lote"
    t.string "fabricante"
    t.text "observacoes"
    t.integer "pet_id", null: false
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_aplicacao"], name: "index_vacinas_on_data_aplicacao"
    t.index ["pet_id"], name: "index_vacinas_on_pet_id"
    t.index ["usuario_id"], name: "index_vacinas_on_usuario_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agendamentos", "pets"
  add_foreign_key "agendamentos", "tutors"
  add_foreign_key "agendamentos", "users", column: "usuario_id"
  add_foreign_key "consultas", "pets"
  add_foreign_key "consultas", "users", column: "usuario_id"
  add_foreign_key "contratos", "pets"
  add_foreign_key "contratos", "tutors"
  add_foreign_key "exames", "pets"
  add_foreign_key "exames", "users", column: "usuario_id"
  add_foreign_key "pesos", "pets"
  add_foreign_key "pesos", "users", column: "usuario_id"
  add_foreign_key "pets", "tutors"
  add_foreign_key "receituarios", "pets"
  add_foreign_key "receituarios", "users", column: "usuario_id"
  add_foreign_key "vacinas", "pets"
  add_foreign_key "vacinas", "users", column: "usuario_id"
end
