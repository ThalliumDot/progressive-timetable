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

ActiveRecord::Schema.define(version: 20171208095011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bug_reports", force: :cascade do |t|
    t.string "full_name"
    t.string "browser"
    t.integer "device"
    t.string "os"
    t.text "problem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faculties", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "course"
    t.integer "faculty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parsed_lessons", force: :cascade do |t|
    t.string "short_name"
    t.string "long_name"
    t.string "lesson_type"
    t.string "teacher"
    t.integer "dates", default: [], array: true
    t.string "timing"
    t.integer "group_id", null: false
    t.string "classroom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
