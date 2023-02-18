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

ActiveRecord::Schema.define(version: 2023_02_14_070526) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "stripe_customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "stripe_price_id"
    t.string "nickname"
    t.string "currency"
    t.string "interval"
    t.integer "amount"
    t.integer "trial_period_days"
    t.string "usage_type"
    t.integer "reference_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reference_number"], name: "index_plans_on_reference_number"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "plan_id"
    t.bigint "user_id"
    t.string "stripe_subscription_id"
    t.integer "trial_start"
    t.integer "trial_end"
    t.boolean "annual", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "units_count", default: 0, null: false
    t.boolean "canceled", default: false, null: false
    t.integer "period_end"
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["user_id", "plan_id"], name: "index_subscriptions_on_user_id_and_plan_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "unit_purchases", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "unit_id"
    t.bigint "user_id"
    t.string "stripe_payment_intent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_unit_purchases_on_customer_id"
    t.index ["unit_id"], name: "index_unit_purchases_on_unit_id"
    t.index ["user_id"], name: "index_unit_purchases_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "plan_id"
    t.integer "amount"
    t.string "stripe_price_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["plan_id"], name: "index_units_on_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "profile"
    t.string "icon"
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.datetime "reset_sent_at"
    t.string "reset_digest"
    t.string "public_uid"
    t.boolean "trial_used", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["public_uid"], name: "index_users_on_public_uid"
  end

end
