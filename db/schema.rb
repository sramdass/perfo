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

ActiveRecord::Schema.define(:version => 20120504092600) do

  create_table "batches", :force => true do |t|
    t.string   "institution_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blood_groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "user_type"
    t.integer  "user_id"
    t.text     "address"
    t.string   "pin"
    t.string   "email"
    t.string   "mobile"
    t.string   "home_phone"
    t.string   "emergency_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_mobile"
    t.string   "parent_email"
  end

  create_table "departments", :force => true do |t|
    t.string   "institution_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exams", :force => true do |t|
    t.string   "institution_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faculties", :force => true do |t|
    t.string   "name"
    t.string   "id_no"
    t.boolean  "female"
    t.string   "qualification"
    t.integer  "designation_id"
    t.integer  "blood_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "image"
  end

  create_table "hods", :force => true do |t|
    t.integer  "department_id"
    t.integer  "faculty_id"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institutions", :force => true do |t|
    t.string   "name"
    t.string   "tipe"
    t.text     "address"
    t.text     "registered_address"
    t.string   "ceo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subdomain"
    t.integer  "tenant_id"
  end

  create_table "pre_college_marks", :force => true do |t|
    t.integer  "school_type_id"
    t.string   "school_name"
    t.float    "percent_marks"
    t.integer  "status"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec_exam_maps", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "section_id"
    t.integer  "exam_id"
    t.integer  "subject_id"
    t.datetime "scheduled_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec_sub_maps", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "section_id"
    t.integer  "subject_id"
    t.integer  "faculty_id"
    t.string   "mark_column"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.integer  "department_id"
    t.integer  "batch_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", :force => true do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "current_semester"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :force => true do |t|
    t.string   "name"
    t.string   "id_no"
    t.boolean  "female"
    t.string   "father_name"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "blood_group_id"
    t.integer  "degree_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "section_id"
  end

  create_table "subjects", :force => true do |t|
    t.string   "institution_id"
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.boolean  "lab"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
