# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_29_232247) do

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "legals", force: :cascade do |t|
    t.string "title", null: false
    t.text "text", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title"], name: "index_legals_on_title"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "city", default: "", null: false
    t.string "zipcode", default: "", null: false
    t.string "time_zone", default: "America/Los_Angeles", null: false
    t.datetime "deleted_at"
    t.string "state", default: "CA"
    t.text "description", default: ""
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer "credits", default: 0, null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "order_number", default: 0, null: false
    t.integer "product_type", default: 0
    t.string "stripe_price_id"
    t.string "label"
    t.datetime "deleted_at"
    t.decimal "price_for_members", precision: 10, scale: 2
    t.string "stripe_product_id"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "products_promo_codes", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "promo_code_id"
    t.index ["product_id"], name: "index_products_promo_codes_on_product_id"
    t.index ["promo_code_id"], name: "index_products_promo_codes_on_promo_code_id"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.integer "discount", default: 0, null: false
    t.string "code", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "expiration_date"
    t.string "stripe_promo_code_id"
    t.string "stripe_coupon_id"
    t.string "duration"
    t.integer "duration_in_months"
    t.integer "max_redemptions"
    t.integer "max_redemptions_by_user"
    t.integer "times_used", default: 0
    t.index ["code"], name: "index_promo_codes_on_code", unique: true
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "credits", null: false
    t.string "name", null: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["product_id"], name: "index_purchases_on_product_id"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "referee_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id"
    t.date "date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.index ["session_id"], name: "index_referee_sessions_on_session_id"
    t.index ["user_id", "session_id", "date"], name: "index_referee_sessions_on_user_id_and_session_id_and_date", unique: true
    t.index ["user_id"], name: "index_referee_sessions_on_user_id"
  end

  create_table "sem_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id"
    t.date "date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.index ["session_id"], name: "index_sem_sessions_on_session_id"
    t.index ["user_id", "session_id", "date"], name: "index_sem_sessions_on_user_id_and_session_id_and_date", unique: true
    t.index ["user_id"], name: "index_sem_sessions_on_user_id"
  end

  create_table "session_exceptions", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.datetime "date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date", "session_id"], name: "index_session_exceptions_on_date_and_session_id"
    t.index ["session_id"], name: "index_session_exceptions_on_session_id"
  end

  create_table "session_survey_answers", force: :cascade do |t|
    t.string "answer"
    t.bigint "session_survey_question_id"
    t.bigint "user_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_survey_question_id"], name: "index_session_survey_answers_on_session_survey_question_id"
    t.index ["user_session_id"], name: "index_session_survey_answers_on_user_session_id"
  end

  create_table "session_survey_questions", force: :cascade do |t|
    t.string "question", null: false
    t.boolean "is_enabled", default: true
    t.boolean "is_mandatory", default: false
    t.integer "type"
    t.index ["type"], name: "index_session_survey_questions_on_type"
  end

  create_table "sessions", force: :cascade do |t|
    t.date "start_time", null: false
    t.text "recurring"
    t.time "time", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "location_id", null: false
    t.date "end_time"
    t.bigint "skill_level_id"
    t.boolean "is_private", default: false
    t.index ["location_id"], name: "index_sessions_on_location_id"
    t.index ["skill_level_id"], name: "index_sessions_on_skill_level_id"
  end

  create_table "skill_levels", force: :cascade do |t|
    t.decimal "min", precision: 2, scale: 1
    t.decimal "max", precision: 2, scale: 1
    t.string "name"
    t.string "description"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "stripe_id"
    t.string "stripe_item_id"
    t.string "status"
    t.boolean "cancel_at_period_end", default: false
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "cancel_at"
    t.datetime "canceled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "product_id"
    t.bigint "promo_code_id"
    t.index ["product_id"], name: "index_subscriptions_on_product_id"
    t.index ["promo_code_id"], name: "index_subscriptions_on_promo_code_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_id"], name: "index_subscriptions_on_stripe_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_promo_codes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "promo_code_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "times_used", default: 0
    t.index ["promo_code_id"], name: "index_user_promo_codes_on_promo_code_id"
    t.index ["user_id"], name: "index_user_promo_codes_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id", null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date", null: false
    t.boolean "checked_in", default: false, null: false
    t.boolean "is_free_session", default: false, null: false
    t.string "free_session_payment_intent"
    t.boolean "credit_reimbursed", default: false, null: false
    t.bigint "referral_id"
    t.boolean "jersey_rental", default: false
    t.string "jersey_rental_payment_intent_id"
    t.string "assigned_team"
    t.index ["session_id"], name: "index_user_sessions_on_session_id"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "phone_number"
    t.integer "credits", default: 0, null: false
    t.boolean "is_referee", default: false, null: false
    t.boolean "is_sem", default: false, null: false
    t.string "stripe_id"
    t.integer "free_session_state", default: 0, null: false
    t.string "free_session_payment_intent"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "zipcode"
    t.date "free_session_expiration_date"
    t.string "referral_code"
    t.integer "subscription_credits", default: 0, null: false
    t.decimal "skill_rating", precision: 2, scale: 1
    t.date "drop_in_expiration_date"
    t.boolean "vaccinated", default: false
    t.boolean "private_access", default: false
    t.integer "active_campaign_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["drop_in_expiration_date"], name: "index_users_on_drop_in_expiration_date"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["free_session_expiration_date"], name: "index_users_on_free_session_expiration_date"
    t.index ["is_referee"], name: "index_users_on_is_referee"
    t.index ["is_sem"], name: "index_users_on_is_sem"
    t.index ["private_access"], name: "index_users_on_private_access"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
