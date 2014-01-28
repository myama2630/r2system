# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140128081148) do

  create_table "businessstatuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "postcode"
    t.string   "address"
    t.string   "phone_no"
    t.string   "destination_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enginemodels", force: true do |t|
    t.string   "modelcode"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "engineorders", force: true do |t|
    t.string   "issue_no"
    t.date     "inquiry_date"
    t.integer  "registered_user_id"
    t.integer  "updated_user_id"
    t.integer  "branch_id"
    t.integer  "salesman_id"
    t.integer  "install_place_id"
    t.string   "orderer"
    t.string   "machine_no"
    t.integer  "time_of_running"
    t.text     "change_comment"
    t.date     "order_date"
    t.integer  "sending_place_id"
    t.text     "sending_comment"
    t.date     "desirable_delivery_date"
    t.integer  "businessstatus_id"
    t.integer  "new_engine_id"
    t.integer  "old_engine_id"
    t.date     "shipped_date"
    t.date     "day_of_test"
    t.string   "title"
    t.date     "returning_date"
    t.text     "returning_comment"
    t.string   "invoice_no_new"
    t.string   "invoice_no_old"
    t.integer  "returning_place_id"
    t.text     "shipped_comment"
    t.date     "allocated_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "engines", force: true do |t|
    t.string   "engine_model_name"
    t.string   "sales_model_name"
    t.string   "serialno"
    t.integer  "enginestatus_id"
    t.integer  "company_id"
    t.boolean  "suspended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enginestatuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repairs", force: true do |t|
    t.string   "issue_no"
    t.date     "issue_date"
    t.date     "arrive_date"
    t.date     "start_date"
    t.date     "finish_date"
    t.text     "before_comment"
    t.text     "after_comment"
    t.integer  "time_of_running"
    t.date     "day_of_test"
    t.text     "arrival_comment"
    t.string   "order_no"
    t.date     "order_date"
    t.string   "construction_no"
    t.date     "desirable_finish_date"
    t.date     "estimated_finish_date"
    t.integer  "engine_id"
    t.date     "shipped_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "requestpaper"
    t.string   "checkpaper"
    t.integer  "billing_id"
    t.date     "billing_date"
    t.integer  "payment_id"
    t.date     "payment_date"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "userid"
    t.string   "name"
    t.string   "category"
    t.string   "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["userid"], name: "index_users_on_userid", unique: true

end
