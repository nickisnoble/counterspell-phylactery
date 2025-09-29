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

ActiveRecord::Schema[8.0].define(version: 2025_09_29_032450) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_hashcash_stamps", force: :cascade do |t|
    t.string "version", null: false
    t.integer "bits", null: false
    t.date "date", null: false
    t.string "resource", null: false
    t.string "ext", null: false
    t.string "rand", null: false
    t.string "counter", null: false
    t.string "request_path"
    t.string "ip_address"
    t.json "context"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["counter", "rand", "date", "resource", "bits", "version", "ext"], name: "index_active_hashcash_stamps_unique", unique: true
    t.index ["ip_address", "created_at"], name: "index_active_hashcash_stamps_on_ip_address_and_created_at", where: "ip_address IS NOT NULL"
  end

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

  create_table "heroes", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "pronouns"
    t.string "ideal"
    t.string "flaw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["slug"], name: "index_heroes_on_slug", unique: true
  end

  create_table "heroes_traits", id: false, force: :cascade do |t|
    t.integer "hero_id", null: false
    t.integer "trait_id", null: false
    t.index ["hero_id"], name: "index_heroes_traits_on_hero_id"
    t.index ["trait_id"], name: "index_heroes_traits_on_trait_id"
  end

  create_table "nondisposable_disposable_domains", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_nondisposable_disposable_domains_on_name", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "traits", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "slug"
    t.text "description"
    t.text "abilities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_traits_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "otp_secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "system_role"
    t.string "pronouns"
    t.boolean "newsletter", default: true
    t.string "slug", null: false
    t.boolean "verified"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "heroes_traits", "heroes"
  add_foreign_key "heroes_traits", "traits"
  add_foreign_key "sessions", "users"
end
