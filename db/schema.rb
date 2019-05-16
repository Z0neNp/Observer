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

ActiveRecord::Schema.define(version: 2019_04_13_092915) do

  create_table "friendly_resources", force: :cascade do |t|
    t.string "name"
    t.integer "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "icmp_flood_reports", force: :cascade do |t|
    t.integer "friendly_resource_id"
    t.boolean "aberrant_behavior"
    t.float "actual_value"
    t.float "baseline"
    t.float "confidence_band_upper_value"
    t.float "estimated_value"
    t.float "linear_trend"
    t.integer "seasonal_index"
    t.float "seasonal_trend"
    t.string "report_type"
    t.float "weighted_avg_abs_deviation"
    t.float "time_spent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendly_resource_id"], name: "index_icmp_flood_reports_on_friendly_resource_id"
  end

  create_table "sql_injection_reports", force: :cascade do |t|
    t.integer "friendly_resource_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendly_resource_id"], name: "index_sql_injection_reports_on_friendly_resource_id"
  end

end
