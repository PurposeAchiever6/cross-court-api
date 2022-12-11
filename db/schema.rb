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

ActiveRecord::Schema.define(version: 2022_12_11_161225) do

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

  create_table "employee_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id"
    t.date "date", null: false
    t.integer "state", default: 0, null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_employee_sessions_on_session_id"
    t.index ["type"], name: "index_employee_sessions_on_type"
    t.index ["user_id"], name: "index_employee_sessions_on_user_id"
  end

  create_table "first_timer_surveys", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "how_did_you_hear_about_us"
    t.index ["user_id"], name: "index_first_timer_surveys_on_user_id"
  end

  create_table "gallery_photos", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "goals", force: :cascade do |t|
    t.integer "category", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.decimal "free_session_miles_radius"
    t.integer "max_sessions_booked_per_day"
    t.integer "max_skill_sessions_booked_per_day"
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_id"
    t.string "brand"
    t.integer "exp_month"
    t.integer "exp_year"
    t.string "last_4"
    t.boolean "default"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description", null: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0"
    t.string "last_4"
    t.string "stripe_id"
    t.integer "status", default: 0
    t.string "error_message"
    t.decimal "cc_cash", precision: 10, scale: 2, default: "0.0"
    t.index ["product_id"], name: "index_payments_on_product_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "player_evaluation_form_section_options", force: :cascade do |t|
    t.string "title"
    t.string "content"
    t.float "score"
    t.bigint "player_evaluation_form_section_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_evaluation_form_section_id"], name: "index_on_player_evaluation_form_section_id"
  end

  create_table "player_evaluation_form_sections", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "required", default: true
    t.index ["title"], name: "index_player_evaluation_form_sections_on_title", unique: true
  end

  create_table "player_evaluation_rating_ranges", force: :cascade do |t|
    t.float "min_score"
    t.float "max_score"
    t.float "rating"
  end

  create_table "player_evaluations", force: :cascade do |t|
    t.bigint "user_id"
    t.json "evaluation", default: {}
    t.float "total_score"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_player_evaluations_on_user_id"
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
    t.decimal "referral_cc_cash", default: "0.0"
    t.decimal "price_for_first_timers_no_free_session", precision: 10, scale: 2
    t.integer "available_for", default: 0
    t.integer "skill_session_credits", default: 0
    t.integer "max_rollover_credits"
    t.boolean "season_pass", default: false
    t.boolean "scouting", default: false
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
    t.index ["product_type"], name: "index_products_on_product_type"
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
    t.boolean "for_referral", default: false
    t.bigint "user_id"
    t.integer "user_max_checked_in_sessions"
    t.index ["code"], name: "index_promo_codes_on_code", unique: true
    t.index ["user_id"], name: "index_promo_codes_on_user_id"
  end

  create_table "session_exceptions", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.date "date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date", "session_id"], name: "index_session_exceptions_on_date_and_session_id"
    t.index ["session_id"], name: "index_session_exceptions_on_session_id"
  end

  create_table "session_guests", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number", null: false
    t.string "email", null: false
    t.string "access_code", null: false
    t.integer "state", default: 0, null: false
    t.bigint "user_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_session_id"], name: "index_session_guests_on_user_session_id"
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
    t.boolean "coming_soon", default: false
    t.boolean "is_open_club", default: false
    t.integer "duration_minutes", default: 60
    t.datetime "deleted_at"
    t.integer "max_first_timers"
    t.boolean "women_only", default: false
    t.boolean "all_skill_levels_allowed", default: true
    t.integer "max_capacity", default: 15
    t.boolean "skill_session", default: false
    t.decimal "cc_cash_earned", default: "0.0"
    t.integer "default_referee_id"
    t.integer "default_sem_id"
    t.integer "default_coach_id"
    t.integer "guests_allowed"
    t.integer "guests_allowed_per_user"
    t.boolean "members_only", default: false
    t.string "theme_title"
    t.string "theme_subheading"
    t.integer "theme_sweat_level"
    t.text "theme_description"
    t.index ["default_coach_id"], name: "index_sessions_on_default_coach_id"
    t.index ["default_referee_id"], name: "index_sessions_on_default_referee_id"
    t.index ["default_sem_id"], name: "index_sessions_on_default_sem_id"
    t.index ["deleted_at"], name: "index_sessions_on_deleted_at"
    t.index ["location_id"], name: "index_sessions_on_location_id"
    t.index ["skill_level_id"], name: "index_sessions_on_skill_level_id"
    t.index ["start_time"], name: "index_sessions_on_start_time"
  end

  create_table "shooting_machine_reservations", force: :cascade do |t|
    t.bigint "shooting_machine_id"
    t.bigint "user_session_id"
    t.integer "status", default: 0
    t.string "charge_payment_intent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "error_on_charge"
    t.index ["shooting_machine_id"], name: "index_shooting_machine_reservations_on_shooting_machine_id"
    t.index ["user_session_id"], name: "index_shooting_machine_reservations_on_user_session_id"
  end

  create_table "shooting_machines", force: :cascade do |t|
    t.bigint "session_id"
    t.float "price", default: 15.0
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_shooting_machines_on_session_id"
  end

  create_table "skill_levels", force: :cascade do |t|
    t.decimal "min", precision: 2, scale: 1
    t.decimal "max", precision: 2, scale: 1
    t.string "name"
    t.string "description"
  end

  create_table "store_items", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subscription_cancellation_requests", force: :cascade do |t|
    t.text "reason"
    t.bigint "user_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["status"], name: "index_subscription_cancellation_requests_on_status"
    t.index ["user_id"], name: "index_subscription_cancellation_requests_on_user_id"
  end

  create_table "subscription_pauses", force: :cascade do |t|
    t.datetime "paused_from", null: false
    t.datetime "paused_until", null: false
    t.bigint "subscription_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "job_id"
    t.integer "status", default: 0
    t.datetime "canceled_at"
    t.datetime "unpaused_at"
    t.string "reason"
    t.index ["subscription_id"], name: "index_subscription_pauses_on_subscription_id"
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
    t.bigint "payment_method_id"
    t.date "mark_cancel_at_period_end_at"
    t.index ["payment_method_id"], name: "index_subscriptions_on_payment_method_id"
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

  create_table "user_session_votes", force: :cascade do |t|
    t.date "date"
    t.bigint "user_id"
    t.bigint "session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date", "session_id", "user_id"], name: "index_user_session_votes_on_date_and_session_id_and_user_id", unique: true
    t.index ["session_id"], name: "index_user_session_votes_on_session_id"
    t.index ["user_id"], name: "index_user_session_votes_on_user_id"
  end

  create_table "user_session_waitlists", force: :cascade do |t|
    t.date "date"
    t.bigint "user_id"
    t.bigint "session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 1
    t.index ["date", "session_id", "user_id"], name: "index_user_session_waitlists_on_date_and_session_id_and_user_id", unique: true
    t.index ["session_id"], name: "index_user_session_waitlists_on_session_id"
    t.index ["user_id"], name: "index_user_session_waitlists_on_user_id"
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
    t.boolean "no_show_up_fee_charged", default: false
    t.datetime "reminder_sent_at"
    t.boolean "first_session", default: false
    t.integer "credit_used_type"
    t.string "goal"
    t.boolean "scouting", default: false
    t.index ["session_id"], name: "index_user_sessions_on_session_id"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "user_update_requests", force: :cascade do |t|
    t.integer "status", default: 0
    t.json "requested_attributes", default: {}
    t.text "reason"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["status"], name: "index_user_update_requests_on_status"
    t.index ["user_id"], name: "index_user_update_requests_on_user_id"
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
    t.boolean "private_access", default: false
    t.integer "active_campaign_id"
    t.date "birthday"
    t.decimal "cc_cash", default: "0.0"
    t.string "source"
    t.boolean "reserve_team", default: false
    t.integer "subscription_skill_session_credits", default: 0
    t.string "instagram_username"
    t.datetime "first_time_subscription_credits_used_at"
    t.boolean "flagged", default: false
    t.boolean "is_coach", default: false, null: false
    t.integer "gender"
    t.integer "credits_without_expiration", default: 0
    t.string "bio"
    t.integer "scouting_credits", default: 0
    t.integer "weight"
    t.integer "height"
    t.string "competitive_basketball_activity"
    t.string "current_basketball_activity"
    t.string "position"
    t.string "goals", array: true
    t.string "main_goal"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["drop_in_expiration_date"], name: "index_users_on_drop_in_expiration_date"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["free_session_expiration_date"], name: "index_users_on_free_session_expiration_date"
    t.index ["is_coach"], name: "index_users_on_is_coach"
    t.index ["is_referee"], name: "index_users_on_is_referee"
    t.index ["is_sem"], name: "index_users_on_is_sem"
    t.index ["private_access"], name: "index_users_on_private_access"
    t.index ["referral_code"], name: "index_users_on_referral_code", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["source"], name: "index_users_on_source"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
