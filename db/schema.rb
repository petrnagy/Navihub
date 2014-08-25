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

ActiveRecord::Schema.define(version: 20140824175429) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cookies", force: true do |t|
    t.integer  "user_id_id"
    t.string   "cookie"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cookies", ["user_id_id"], name: "index_cookies_on_user_id_id", using: :btree

  create_table "credentials", force: true do |t|
    t.integer  "user_id_id"
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credentials", ["user_id_id"], name: "index_credentials_on_user_id_id", using: :btree

  create_table "facebook_sessions", force: true do |t|
    t.integer  "user_id_id"
    t.datetime "valid"
    t.datetime "expires"
    t.datetime "issued"
    t.binary   "session_ser"
    t.binary   "info_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_sessions", ["user_id_id"], name: "index_facebook_sessions_on_user_id_id", using: :btree

  create_table "google_sessions", force: true do |t|
    t.integer  "user_id_id"
    t.datetime "valid"
    t.datetime "expires"
    t.datetime "issued"
    t.text     "token_json"
    t.binary   "info_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_sessions", ["user_id_id"], name: "index_google_sessions_on_user_id_id", using: :btree

  create_table "langs", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "get"
    t.string   "set"
    t.string   "delete"
    t.integer  "user_id_id"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country"
    t.string   "country_short"
    t.string   "city"
    t.string   "city2"
    t.string   "street1"
    t.string   "street2"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["user_id_id"], name: "index_locations_on_user_id_id", using: :btree

  create_table "sessions", force: true do |t|
    t.integer  "user_id_id"
    t.integer  "cookie_id_id"
    t.string   "sessid"
    t.datetime "valid"
    t.boolean  "remember"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["cookie_id_id"], name: "index_sessions_on_cookie_id_id", using: :btree
  add_index "sessions", ["user_id_id"], name: "index_sessions_on_user_id_id", using: :btree

  create_table "twitter_sessions", force: true do |t|
    t.integer  "user_id_id"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "valid"
    t.binary   "conn_ser"
    t.binary   "credentials_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twitter_sessions", ["user_id_id"], name: "index_twitter_sessions_on_user_id_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "id_fb"
    t.string   "id_tw"
    t.string   "id_gp"
    t.string   "name"
    t.string   "imgurl"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vars", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
