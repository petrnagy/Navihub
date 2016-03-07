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

ActiveRecord::Schema.define(version: 20160305190137) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_caches", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
    t.text     "data"
  end

  add_index "api_caches", ["key"], name: "index_api_caches_on_key", unique: true, using: :btree

  create_table "cookies", force: true do |t|
    t.integer  "user_id"
    t.string   "cookie"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cookies", ["active"], name: "index_cookies_on_active", using: :btree
  add_index "cookies", ["cookie"], name: "index_cookies_on_cookie", unique: true, using: :btree
  add_index "cookies", ["user_id"], name: "index_cookies_on_user_id", using: :btree

  create_table "credentials", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "credentials", ["active"], name: "index_credentials_on_active", using: :btree
  add_index "credentials", ["email"], name: "index_credentials_on_email", unique: true, using: :btree
  add_index "credentials", ["password"], name: "index_credentials_on_password", using: :btree
  add_index "credentials", ["salt"], name: "index_credentials_on_salt", using: :btree
  add_index "credentials", ["user_id"], name: "index_credentials_on_user_id", using: :btree
  add_index "credentials", ["username"], name: "index_credentials_on_username", unique: true, using: :btree

  create_table "distance_matrix_caches", force: true do |t|
    t.string   "source"
    t.string   "destination"
    t.text     "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distance_matrix_caches", ["source", "destination"], name: "index_distance_matrix_caches_on_source_and_destination", unique: true, using: :btree

  create_table "emails", force: true do |t|
    t.string   "recipient"
    t.string   "sender"
    t.text     "subject"
    t.text     "content"
    t.string   "email_type"
    t.integer  "tries"
    t.datetime "sent"
    t.string   "email_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facebook_sessions", force: true do |t|
    t.integer  "user_id"
    t.datetime "valid_to"
    t.datetime "expires"
    t.datetime "issued"
    t.binary   "session_ser"
    t.binary   "info_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_sessions", ["active"], name: "index_facebook_sessions_on_active", using: :btree
  add_index "facebook_sessions", ["user_id"], name: "index_facebook_sessions_on_user_id", using: :btree
  add_index "facebook_sessions", ["valid_to"], name: "index_facebook_sessions_on_valid_to", using: :btree

  create_table "favorites", force: true do |t|
    t.string   "venue_origin"
    t.string   "venue_id"
    t.integer  "user_id"
    t.text     "yield"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "forms", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "email"
    t.text     "text"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spam"
    t.string   "key"
  end

  add_index "forms", ["key"], name: "index_forms_on_key", unique: true, using: :btree

  create_table "geocode_caches", force: true do |t|
    t.string   "addr"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geocode_caches", ["addr"], name: "index_geocode_caches_on_addr", unique: true, using: :btree
  add_index "geocode_caches", ["latitude", "longitude"], name: "index_geocode_caches_on_latitude_and_longitude", using: :btree

  create_table "google_sessions", force: true do |t|
    t.integer  "user_id"
    t.datetime "valid_to"
    t.datetime "expires"
    t.datetime "issued"
    t.text     "token_json"
    t.binary   "info_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_sessions", ["active"], name: "index_google_sessions_on_active", using: :btree
  add_index "google_sessions", ["user_id"], name: "index_google_sessions_on_user_id", using: :btree
  add_index "google_sessions", ["valid_to"], name: "index_google_sessions_on_valid_to", using: :btree

  create_table "google_static_map_caches", force: true do |t|
    t.string   "url",                     limit: 1000
    t.boolean  "found"
    t.string   "x_staticmap_api_warning"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_static_map_caches", ["found"], name: "index_google_static_map_caches_on_found", using: :btree
  add_index "google_static_map_caches", ["url"], name: "index_google_static_map_caches_on_url", unique: true, using: :btree

  create_table "ipinfo_caches", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ipv4"
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "ipinfo_caches", ["ipv4"], name: "index_ipinfo_caches_on_ipv4", unique: true, using: :btree
  add_index "ipinfo_caches", ["updated_at"], name: "index_ipinfo_caches_on_updated_at", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "user_id"
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
    t.boolean  "lock"
  end

  add_index "locations", ["active"], name: "index_locations_on_active", using: :btree
  add_index "locations", ["latitude"], name: "index_locations_on_latitude", using: :btree
  add_index "locations", ["longitude"], name: "index_locations_on_longitude", using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "login_sessions", force: true do |t|
    t.integer  "user_id"
    t.integer  "cookie_id"
    t.integer  "session_id"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "extended"
  end

  add_index "login_sessions", ["cookie_id"], name: "index_login_sessions_on_cookie_id", using: :btree
  add_index "login_sessions", ["session_id"], name: "index_login_sessions_on_session_id", using: :btree
  add_index "login_sessions", ["user_id"], name: "index_login_sessions_on_user_id", using: :btree

  create_table "permalinks", force: true do |t|
    t.string   "venue_origin"
    t.string   "venue_id"
    t.text     "yield"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "permalink_id"
  end

  add_index "permalinks", ["permalink_id"], name: "index_permalinks_on_permalink_id", using: :btree
  add_index "permalinks", ["user_id"], name: "index_permalinks_on_user_id", using: :btree

  create_table "reverse_geocode_caches", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "addr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reverse_geocode_caches", ["addr"], name: "index_reverse_geocode_caches_on_addr", using: :btree
  add_index "reverse_geocode_caches", ["latitude", "longitude"], name: "index_reverse_geocode_caches_on_latitude_and_longitude", unique: true, using: :btree
  add_index "reverse_geocode_caches", ["updated_at"], name: "index_reverse_geocode_caches_on_updated_at", using: :btree

  create_table "sessions", force: true do |t|
    t.integer  "user_id"
    t.integer  "cookie_id"
    t.string   "sessid"
    t.datetime "valid_to"
    t.boolean  "remember"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["active"], name: "index_sessions_on_active", using: :btree
  add_index "sessions", ["cookie_id"], name: "index_sessions_on_cookie_id", using: :btree
  add_index "sessions", ["sessid"], name: "index_sessions_on_sessid", unique: true, using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "twitter_sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "valid_to"
    t.binary   "conn_ser"
    t.binary   "credentials_ser"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twitter_sessions", ["active"], name: "index_twitter_sessions_on_active", using: :btree
  add_index "twitter_sessions", ["user_id"], name: "index_twitter_sessions_on_user_id", using: :btree

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

  add_index "users", ["active"], name: "index_users_on_active", using: :btree
  add_index "users", ["id_fb"], name: "index_users_on_id_fb", using: :btree
  add_index "users", ["id_gp"], name: "index_users_on_id_gp", using: :btree
  add_index "users", ["id_tw"], name: "index_users_on_id_tw", using: :btree

  create_table "venue_detail_caches", force: true do |t|
    t.string   "venue_origin"
    t.string   "venue_id"
    t.text     "yield"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
