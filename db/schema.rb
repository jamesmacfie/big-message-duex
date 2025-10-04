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

ActiveRecord::Schema[7.2].define(version: 2025_10_04_042343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "people", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.text "description"
    t.boolean "is_agent", default: false, null: false
    t.text "agent_prompt"
    t.string "theme", default: "light"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_agent"], name: "index_people_on_is_agent"
    t.index ["user_id"], name: "index_people_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "email_confirmed_at"
    t.string "email_confirmation_token"
    t.datetime "email_confirmation_sent_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_confirmation_token"], name: "index_users_on_email_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "people", "users"
end
