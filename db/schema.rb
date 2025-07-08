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

ActiveRecord::Schema[7.1].define(version: 2025_07_08_210445) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "print_jobs", force: :cascade do |t|
    t.bigint "patron_id", null: false
    t.integer "status"
    t.text "description"
    t.integer "quantity"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patron_id"], name: "index_print_jobs_on_patron_id"
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
    t.index ["email"], name: "index_staff_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staff_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_staff_users_on_uid", unique: true
  end

  add_foreign_key "print_jobs", "patrons"
end
