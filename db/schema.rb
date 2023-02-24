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

ActiveRecord::Schema[7.0].define(version: 2023_02_24_174957) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subdomain"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "source_id"
    t.string "title"
    t.string "url"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_items_on_account_id"
    t.index ["source_id"], name: "index_items_on_source_id"
  end

  create_table "que_jobs", comment: "7", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.timestamptz "run_at", default: -> { "now()" }, null: false
    t.text "job_class", null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error_message"
    t.text "queue", default: "default", null: false
    t.text "last_error_backtrace"
    t.timestamptz "finished_at"
    t.timestamptz "expired_at"
    t.jsonb "args", default: [], null: false
    t.jsonb "data", default: {}, null: false
    t.integer "job_schema_version", null: false
    t.jsonb "kwargs", default: {}, null: false
    t.index ["args"], name: "que_jobs_args_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["data"], name: "que_jobs_data_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["job_class"], name: "que_scheduler_job_in_que_jobs_unique_index", unique: true, where: "(job_class = 'Que::Scheduler::SchedulerJob'::text)"
    t.index ["job_schema_version", "queue", "priority", "run_at", "id"], name: "que_poll_idx", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.index ["kwargs"], name: "que_jobs_kwargs_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.check_constraint "char_length(\nCASE job_class\n    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN (args -> 0) ->> 'job_class'::text\n    ELSE job_class\nEND) <= 200", name: "job_class_length"
    t.check_constraint "char_length(last_error_message) <= 500 AND char_length(last_error_backtrace) <= 10000", name: "error_length"
    t.check_constraint "char_length(queue) <= 100", name: "queue_length"
    t.check_constraint "jsonb_typeof(args) = 'array'::text", name: "valid_args"
    t.check_constraint "jsonb_typeof(data) = 'object'::text AND (NOT data ? 'tags'::text OR jsonb_typeof(data -> 'tags'::text) = 'array'::text AND jsonb_array_length(data -> 'tags'::text) <= 5 AND que_validate_tags(data -> 'tags'::text))", name: "valid_data"
  end

  create_table "que_lockers", primary_key: "pid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "worker_count", null: false
    t.integer "worker_priorities", null: false, array: true
    t.integer "ruby_pid", null: false
    t.text "ruby_hostname", null: false
    t.text "queues", null: false, array: true
    t.boolean "listening", null: false
    t.integer "job_schema_version", default: 1
    t.check_constraint "array_ndims(queues) = 1 AND array_length(queues, 1) IS NOT NULL", name: "valid_queues"
    t.check_constraint "array_ndims(worker_priorities) = 1 AND array_length(worker_priorities, 1) IS NOT NULL", name: "valid_worker_priorities"
  end

  create_table "que_scheduler_audit", primary_key: "scheduler_job_id", id: :bigint, default: nil, comment: "7", force: :cascade do |t|
    t.timestamptz "executed_at", null: false
  end

  create_table "que_scheduler_audit_enqueued", id: false, force: :cascade do |t|
    t.bigint "scheduler_job_id", null: false
    t.string "job_class", limit: 255, null: false
    t.string "queue", limit: 255
    t.integer "priority"
    t.jsonb "args", null: false
    t.bigint "job_id"
    t.timestamptz "run_at"
    t.index ["args"], name: "que_scheduler_audit_enqueued_args"
    t.index ["job_class"], name: "que_scheduler_audit_enqueued_job_class"
    t.index ["job_id"], name: "que_scheduler_audit_enqueued_job_id"
  end

  create_table "que_values", primary_key: "key", id: :text, force: :cascade do |t|
    t.jsonb "value", default: {}, null: false
    t.check_constraint "jsonb_typeof(value) = 'object'::text", name: "valid_value"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.uuid "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "title"
    t.string "url"
    t.datetime "fetched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sources_on_account_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "items", "accounts"
  add_foreign_key "items", "sources"
  add_foreign_key "que_scheduler_audit_enqueued", "que_scheduler_audit", column: "scheduler_job_id", primary_key: "scheduler_job_id", name: "que_scheduler_audit_enqueued_scheduler_job_id_fkey"
  add_foreign_key "sources", "accounts"
end
