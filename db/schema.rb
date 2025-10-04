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

ActiveRecord::Schema[7.2].define(version: 2025_10_04_082245) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "channels", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "channel_type", default: "channel", null: false
    t.boolean "is_private", default: false, null: false
    t.datetime "archived_at"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_channels_on_archived_at"
    t.index ["channel_type"], name: "index_channels_on_channel_type"
    t.index ["created_by_id"], name: "index_channels_on_created_by_id"
    t.index ["name"], name: "index_channels_on_name"
  end

  create_table "invites", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.bigint "invited_by_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_invites_on_archived_at"
    t.index ["email"], name: "index_invites_on_email"
    t.index ["invited_by_id"], name: "index_invites_on_invited_by_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "channel_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "last_viewed_at"
    t.datetime "typing_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_members_on_channel_id"
    t.index ["person_id", "channel_id"], name: "index_members_on_person_id_and_channel_id", unique: true
    t.index ["person_id"], name: "index_members_on_person_id"
    t.index ["role"], name: "index_members_on_role"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "channel_id", null: false
    t.text "content"
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_message_id"
    t.index ["channel_id", "created_at"], name: "index_messages_on_channel_id_and_created_at"
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["edited_at"], name: "index_messages_on_edited_at"
    t.index ["parent_message_id"], name: "index_messages_on_parent_message_id"
    t.index ["person_id"], name: "index_messages_on_person_id"
  end

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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "channels", "people", column: "created_by_id"
  add_foreign_key "invites", "people", column: "invited_by_id"
  add_foreign_key "members", "channels"
  add_foreign_key "members", "people"
  add_foreign_key "messages", "channels"
  add_foreign_key "messages", "messages", column: "parent_message_id"
  add_foreign_key "messages", "people"
  add_foreign_key "people", "users"
end
