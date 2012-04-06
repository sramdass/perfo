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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120406170633) do

  create_table "tenants", :force => true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.string   "email"
    t.string   "phone"
    t.date     "subscription_from"
    t.date     "subscription_to"
    t.string   "activation_token"
    t.boolean  "activated"
    t.boolean  "locked"
    t.string   "schema_username"
    t.string   "schema_password"
    t.integer  "students_count"
    t.integer  "faculties_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
