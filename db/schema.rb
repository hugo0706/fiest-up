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

ActiveRecord::Schema[7.2].define(version: 2024_10_19_172732) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "parties", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "device_id"
    t.boolean "started", default: false, null: false
    t.integer "next_song_job_id"
    t.boolean "stopped", default: false, null: false
    t.index ["code"], name: "index_parties_on_code", unique: true
    t.index ["user_id", "name"], name: "index_parties_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_parties_on_user_id"
  end

  create_table "party_songs", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "party_id", null: false
    t.boolean "is_playing", default: false, null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "next_song", default: false, null: false
    t.boolean "played", default: false
    t.index ["party_id", "position"], name: "index_party_songs_on_party_id_and_position", unique: true
    t.index ["party_id"], name: "index_party_songs_on_party_id"
    t.index ["song_id"], name: "index_party_songs_on_song_id"
  end

  create_table "party_users", force: :cascade do |t|
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.bigint "party_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_id", "user_id"], name: "index_party_users_on_party_id_and_user_id", unique: true
    t.index ["party_id"], name: "index_party_users_on_party_id"
    t.index ["user_type", "user_id"], name: "index_party_users_on_user"
  end

  create_table "songs", force: :cascade do |t|
    t.string "spotify_song_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "artists", default: [], array: true
    t.string "image"
    t.string "uri", null: false
    t.integer "duration", null: false
    t.index ["spotify_song_id"], name: "index_songs_on_spotify_song_id", unique: true
  end

  create_table "temporal_users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "access_token", limit: 510, null: false
    t.string "spotify_id", null: false
    t.string "refresh_token", limit: 510, null: false
    t.string "email", null: false
    t.string "username", null: false
    t.string "product", null: false
    t.string "profile_url", null: false
    t.datetime "access_token_expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_users_on_spotify_id", unique: true
  end

  add_foreign_key "parties", "users"
  add_foreign_key "party_songs", "parties"
  add_foreign_key "party_songs", "songs"
  add_foreign_key "party_users", "parties"
end
