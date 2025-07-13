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

ActiveRecord::Schema[7.1].define(version: 2025_07_13_015928) do
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

  create_table "conversations", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_conversations_on_job_id"
  end

  create_table "filament_colors", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "patron_id", null: false
    t.integer "status"
    t.text "description"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "filament_color"
    t.string "pickup_location"
    t.string "category"
    t.string "print_type", default: "FDM", null: false
    t.integer "print_time_estimate"
    t.decimal "slicer_weight", precision: 10, scale: 2
    t.decimal "slicer_cost", precision: 10, scale: 2
    t.decimal "actual_weight", precision: 10, scale: 2
    t.decimal "actual_cost", precision: 10, scale: 2
    t.date "completion_date"
    t.bigint "assigned_printer_id"
    t.boolean "spray_ok", default: false, null: false, comment: "Whether it’s OK to apply scanning spray/powder to the object"
    t.string "type", default: "PrintJob", null: false
    t.index ["assigned_printer_id"], name: "index_jobs_on_assigned_printer_id"
    t.index ["patron_id"], name: "index_jobs_on_patron_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "author_type", null: false
    t.bigint "author_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "staff_note_only", default: false, null: false
    t.index ["author_type", "author_id"], name: "index_messages_on_author"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "patrons", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "access_token"
    t.datetime "token_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_patrons_on_access_token", unique: true
    t.index ["email"], name: "index_patrons_on_email", unique: true
  end

  create_table "pickup_locations", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "print_job_notes", force: :cascade do |t|
    t.bigint "print_job_id", null: false
    t.text "content"
    t.string "new_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["print_job_id"], name: "index_print_job_notes_on_print_job_id"
  end

  create_table "printers", force: :cascade do |t|
    t.string "name", null: false
    t.string "printer_type"
    t.string "printer_model"
    t.string "bed_size"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_printers_on_name", unique: true
  end

  create_table "staff_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "avatar_url"
    t.string "uid", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_staff_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staff_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_staff_users_on_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "jobs"
  add_foreign_key "conversations", "jobs"
  add_foreign_key "jobs", "patrons"
  add_foreign_key "jobs", "printers", column: "assigned_printer_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "print_job_notes", "jobs", column: "print_job_id"
end
