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

ActiveRecord::Schema[8.0].define(version: 2026_07_11_191117) do
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

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
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
    t.index ["nome"], name: "index_pets_on_nome"
    t.index ["tutor_id"], name: "index_pets_on_tutor_id"
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

  add_foreign_key "consultas", "pets"
  add_foreign_key "consultas", "users", column: "usuario_id"
  add_foreign_key "pets", "tutors"
  add_foreign_key "vacinas", "pets"
  add_foreign_key "vacinas", "users", column: "usuario_id"
end
