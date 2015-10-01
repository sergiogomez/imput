class FirstSchema < ActiveRecord::Migration
  def change

    create_table "clients", force: true do |t|
      t.string   "name"
      t.string   "address"
      t.text     "notes"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "company_id"
      t.boolean  "enabled",    default: true
    end

    add_index "clients", ["company_id"], name: "index_clients_on_company_id", using: :btree

    create_table "companies", force: true do |t|
      t.string   "name"
      t.text     "notes"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "billing_email"
    end

    create_table "members", force: true do |t|
      t.text     "notes"
      t.integer  "person_id"
      t.integer  "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "project_manager", default: false
    end

    add_index "members", ["person_id"], name: "index_members_on_person_id", using: :btree
    add_index "members", ["project_id"], name: "index_members_on_project_id", using: :btree

    create_table "people", force: true do |t|
      t.string   "firstname"
      t.string   "lastname"
      t.text     "notes"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email",                  default: "",    null: false
      t.string   "encrypted_password",     default: "",    null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,     null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet     "current_sign_in_ip"
      t.inet     "last_sign_in_ip"
      t.integer  "company_id"
      t.boolean  "admin",                  default: false
      t.integer  "current_time_entry_id"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.boolean  "receive_daily_report",   default: false
      t.boolean  "time_decimal",           default: true
      t.boolean  "enabled",                default: true
      t.string   "authentication_token"
      t.float    "max_hours",              default: 8.0
    end

    add_index "people", ["authentication_token"], name: "index_people_on_authentication_token", unique: true, using: :btree
    add_index "people", ["company_id"], name: "index_people_on_company_id", using: :btree
    add_index "people", ["confirmation_token"], name: "index_people_on_confirmation_token", unique: true, using: :btree
    add_index "people", ["current_time_entry_id"], name: "index_people_on_current_time_entry_id", using: :btree
    add_index "people", ["email"], name: "index_people_on_email", unique: true, using: :btree
    add_index "people", ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true, using: :btree

    create_table "projects", force: true do |t|
      t.string   "name"
      t.text     "notes"
      t.integer  "client_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "company_id"
      t.boolean  "enabled",    default: true
    end

    add_index "projects", ["client_id"], name: "index_projects_on_client_id", using: :btree
    add_index "projects", ["company_id"], name: "index_projects_on_company_id", using: :btree

    create_table "reminders", force: true do |t|
      t.string   "text"
      t.datetime "notify_at"
      t.string   "job_id"
      t.integer  "time_entry_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "reminders", ["time_entry_id"], name: "index_reminders_on_time_entry_id", using: :btree

    create_table "rows", force: true do |t|
      t.integer  "person_id"
      t.integer  "project_id"
      t.integer  "task_id"
      t.date     "stored_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "rows", ["person_id"], name: "index_rows_on_person_id", using: :btree
    add_index "rows", ["project_id"], name: "index_rows_on_project_id", using: :btree
    add_index "rows", ["task_id"], name: "index_rows_on_task_id", using: :btree

    create_table "task_assignments", force: true do |t|
      t.text     "notes"
      t.integer  "task_id"
      t.integer  "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "task_assignments", ["project_id"], name: "index_task_assignments_on_project_id", using: :btree
    add_index "task_assignments", ["task_id"], name: "index_task_assignments_on_task_id", using: :btree

    create_table "tasks", force: true do |t|
      t.string   "name"
      t.text     "notes"
      t.boolean  "common",     default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "company_id"
    end

    add_index "tasks", ["company_id"], name: "index_tasks_on_company_id", using: :btree

    create_table "time_entries", force: true do |t|
      t.float    "hours"
      t.date     "spent_on"
      t.datetime "begun_on"
      t.integer  "person_id"
      t.integer  "project_id"
      t.integer  "task_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "timer_running",    default: false
      t.integer  "active_person_id"
      t.text     "notes"
      t.boolean  "is_adjust",        default: false
      t.boolean  "notified",         default: false
    end

    add_index "time_entries", ["active_person_id"], name: "index_time_entries_on_active_person_id", using: :btree
    add_index "time_entries", ["person_id"], name: "index_time_entries_on_person_id", using: :btree
    add_index "time_entries", ["project_id"], name: "index_time_entries_on_project_id", using: :btree
    add_index "time_entries", ["task_id"], name: "index_time_entries_on_task_id", using: :btree

  end
end
