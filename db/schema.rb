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

ActiveRecord::Schema[7.2].define(version: 2024_11_16_051111) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
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

  create_table "announcements", force: :cascade do |t|
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_preferences", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "pref_type"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string "bldrecnbr"
    t.string "name"
    t.string "nick_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "zone_id"
    t.boolean "archived", default: false
    t.index ["zone_id"], name: "index_buildings_on_zone_id"
  end

  create_table "common_attribute_states", force: :cascade do |t|
    t.boolean "checkbox_value"
    t.integer "quantity_box_value"
    t.bigint "room_state_id", null: false
    t.bigint "common_attribute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_attribute_id"], name: "index_common_attribute_states_on_common_attribute_id"
    t.index ["room_state_id"], name: "index_common_attribute_states_on_room_state_id"
  end

  create_table "common_attributes", force: :cascade do |t|
    t.string "description"
    t.boolean "need_checkbox"
    t.boolean "need_quantity_box"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false
  end

  create_table "floors", force: :cascade do |t|
    t.string "name"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_floors_on_building_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_notes_on_room_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "resource_states", force: :cascade do |t|
    t.boolean "is_checked"
    t.bigint "room_state_id", null: false
    t.bigint "resource_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id"], name: "index_resource_states_on_resource_id"
    t.index ["room_state_id"], name: "index_resource_states_on_room_state_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false
    t.index ["room_id"], name: "index_resources_on_room_id"
  end

  create_table "room_states", force: :cascade do |t|
    t.string "checked_by"
    t.boolean "is_accessed"
    t.boolean "report_to_supervisor"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "no_access_reason"
    t.index ["room_id"], name: "index_room_states_on_room_id"
    t.index ["updated_at"], name: "index_room_states_on_updated_at"
  end

  create_table "room_tickets", force: :cascade do |t|
    t.string "description"
    t.string "submitted_by"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tdx_email"
    t.index ["room_id"], name: "index_room_tickets_on_room_id"
  end

  create_table "room_update_logs", force: :cascade do |t|
    t.date "date"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "rmrecnbr"
    t.string "room_number"
    t.string "room_type"
    t.bigint "floor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_time_checked"
    t.boolean "archived", default: false
    t.index ["floor_id"], name: "index_rooms_on_floor_id"
  end

  create_table "rovers", force: :cascade do |t|
    t.string "uniqname"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "specific_attribute_states", force: :cascade do |t|
    t.boolean "checkbox_value"
    t.integer "quantity_box_value"
    t.bigint "room_state_id", null: false
    t.bigint "specific_attribute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_state_id"], name: "index_specific_attribute_states_on_room_state_id"
    t.index ["specific_attribute_id"], name: "index_specific_attribute_states_on_specific_attribute_id"
  end

  create_table "specific_attributes", force: :cascade do |t|
    t.string "description"
    t.boolean "need_checkbox"
    t.boolean "need_quantity_box"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false
    t.index ["room_id"], name: "index_specific_attributes_on_room_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "uniqname"
    t.string "principal_name"
    t.string "display_name"
    t.string "person_affiliation"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "buildings", "zones"
  add_foreign_key "common_attribute_states", "common_attributes"
  add_foreign_key "common_attribute_states", "room_states"
  add_foreign_key "floors", "buildings"
  add_foreign_key "notes", "rooms"
  add_foreign_key "notes", "users"
  add_foreign_key "resource_states", "resources"
  add_foreign_key "resource_states", "room_states"
  add_foreign_key "resources", "rooms"
  add_foreign_key "room_states", "rooms"
  add_foreign_key "room_tickets", "rooms"
  add_foreign_key "rooms", "floors"
  add_foreign_key "specific_attribute_states", "room_states"
  add_foreign_key "specific_attribute_states", "specific_attributes"
  add_foreign_key "specific_attributes", "rooms"
end
