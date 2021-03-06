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

ActiveRecord::Schema.define(:version => 20120925093946) do

  create_table "arrear_students", :force => true do |t|
    t.integer  "section_id"
    t.integer  "semester_id"
    t.integer  "subject_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "exam_type",      :default => 0
    t.integer  "examination_id"
    t.boolean  "finals"
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

  create_table "grade_criteria", :force => true do |t|
    t.string   "name"
    t.string   "color_code"
    t.float    "cut_off_percentage"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grades", :force => true do |t|
    t.string   "name"
    t.string   "color_code"
    t.float    "cut_off_percentage"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "mark_criteria", :force => true do |t|
    t.integer  "section_id"
    t.integer  "subject_id"
    t.integer  "semester_id"
    t.integer  "exam_id"
    t.float    "max_marks"
    t.float    "pass_marks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marks", :force => true do |t|
    t.integer  "student_id"
    t.integer  "semester_id"
    t.integer  "section_id"
    t.integer  "exam_id"
    t.float    "sub1"
    t.float    "sub2"
    t.float    "sub3"
    t.float    "sub4"
    t.float    "sub5"
    t.float    "sub6"
    t.float    "sub7"
    t.float    "sub8"
    t.float    "sub9"
    t.float    "sub10"
    t.float    "sub11"
    t.float    "sub12"
    t.float    "sub13"
    t.float    "sub14"
    t.float    "sub15"
    t.float    "sub16"
    t.float    "sub17"
    t.float    "sub18"
    t.float    "sub19"
    t.float    "sub20"
    t.float    "total"
    t.string   "grade"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_credits"
    t.float    "weighed_total_percentage"
    t.integer  "passed_count"
    t.integer  "arrears_count"
    t.integer  "arrear_student_id"
    t.float    "weighed_pass_marks_percentage"
    t.float    "weighed_total_percentage_ia"
    t.integer  "passed_count_ia"
    t.integer  "arrears_count_ia"
    t.float    "weighed_pass_marks_percentage_ia"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id"
    t.integer  "resource_id"
    t.integer  "privilege"
    t.integer  "constraints"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "resource_actions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "code"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_memberships", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
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
    t.integer  "credits",     :default => 1
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
    t.string   "image"
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

  create_table "user_profiles", :force => true do |t|
    t.string   "login"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "password_reset_token"
    t.string   "auth_token"
    t.datetime "password_reset_sent_at"
    t.string   "user_type"
    t.integer  "user_id"
    t.datetime "last_login_at"
    t.boolean  "activated"
    t.boolean  "locked"
    t.integer  "failed_login_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id"
  end

end
