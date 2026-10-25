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

ActiveRecord::Schema[8.0].define(version: 2026_10_09_010614) do
  create_schema "chatia"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "public.vector"
  enable_extension "unaccent"

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "llm_model_id"
    t.string "title", default: "Nova conversa", null: false
    t.text "system_prompt_content"
    t.text "summary"
    t.integer "total_input_tokens", default: 0, null: false
    t.integer "total_output_tokens", default: 0, null: false
    t.decimal "total_cost_usd", precision: 12, scale: 6, default: "0.0", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_model_id"], name: "index_conversations_on_llm_model_id"
    t.index ["user_id", "created_at"], name: "index_conversations_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_conversations_on_user_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "llm_model_id"
    t.string "title", default: "Nova conversa", null: false
    t.text "system_prompt_content"
    t.text "summary"
    t.integer "total_input_tokens", default: 0, null: false
    t.integer "total_output_tokens", default: 0, null: false
    t.decimal "total_cost_usd", precision: 12, scale: 6, default: "0.0", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_model_id"], name: "index_conversations_on_llm_model_id"
    t.index ["user_id", "created_at"], name: "index_conversations_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_conversations_on_user_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "document_chunks", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.integer "position", null: false
    t.text "content", null: false
    t.tsvector "tsv"
    t.vector "embedding", limit: 384
    t.string "embedding_model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id", "position"], name: "index_document_chunks_on_document_id_and_position"
    t.index ["document_id"], name: "index_document_chunks_on_document_id"
    t.index ["tsv"], name: "index_document_chunks_on_tsv", using: :gin
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "conversation_id"
    t.string "filename", null: false
    t.string "content_type", null: false
    t.bigint "byte_size", null: false
    t.string "status", default: "uploaded", null: false
    t.text "extracted_text"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_documents_on_conversation_id"
    t.index ["status"], name: "index_documents_on_status"
    t.index ["user_id", "created_at"], name: "index_documents_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "knowledge_chunks", force: :cascade do |t|
    t.text "content", null: false
    t.string "category", null: false
    t.string "cefr_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "cefr_level"], name: "index_knowledge_chunks_on_category_and_cefr_level"
  end

  create_table "learner_gaps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "category", null: false
    t.integer "occurrences", default: 1, null: false
    t.datetime "last_seen_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "category"], name: "index_learner_gaps_on_user_id_and_category", unique: true
    t.index ["user_id", "occurrences"], name: "index_learner_gaps_on_user_id_and_occurrences"
    t.index ["user_id"], name: "index_learner_gaps_on_user_id"
  end

  create_table "llm_models", force: :cascade do |t|
    t.string "provider_id", null: false
    t.string "name", null: false
    t.string "display_name"
    t.decimal "input_price_per_million_tokens", precision: 12, scale: 6
    t.decimal "output_price_per_million_tokens", precision: 12, scale: 6
    t.integer "context_window"
    t.boolean "active", default: true, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_llm_models_on_active"
    t.index ["provider_id"], name: "index_llm_models_on_provider_id", unique: true
  end

  create_table "message_analyses", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.jsonb "grammar_errors", default: []
    t.jsonb "suggestions", default: []
    t.string "cefr"
    t.jsonb "metrics", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_analyses_on_message_id", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "role", null: false
    t.text "content", default: "", null: false
    t.string "status", default: "pending", null: false
    t.string "llm_model_provider_id"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.decimal "cost_usd", precision: 12, scale: 6
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["embedding"], name: "index_messages_on_embedding_hnsw", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["status"], name: "index_messages_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "role", null: false
    t.text "content", default: "", null: false
    t.string "status", default: "pending", null: false
    t.string "llm_model_provider_id"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.decimal "cost_usd", precision: 12, scale: 6
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["embedding"], name: "index_messages_on_embedding_hnsw", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["status"], name: "index_messages_on_status"
  end

  create_table "system_prompts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "content", null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_system_prompts_on_active"
    t.index ["topic", "cefr_level"], name: "index_system_prompts_on_topic_and_cefr_level"
    t.index ["user_id", "is_default"], name: "index_system_prompts_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_system_prompts_on_user_id"
  end

  create_table "system_prompts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "content", null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_system_prompts_on_active"
    t.index ["topic", "cefr_level"], name: "index_system_prompts_on_topic_and_cefr_level"
    t.index ["user_id", "is_default"], name: "index_system_prompts_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_system_prompts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "llm_models"
  add_foreign_key "conversations", "public.users"
  add_foreign_key "conversations", "users"
  add_foreign_key "conversations", "llm_models"
  add_foreign_key "conversations", "public.users"
  add_foreign_key "conversations", "users"
  add_foreign_key "document_chunks", "documents"
  add_foreign_key "documents", "conversations"
  add_foreign_key "documents", "users"
  add_foreign_key "learner_gaps", "public.users"
  add_foreign_key "message_analyses", "public.messages"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "public.conversations"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "public.conversations"
  add_foreign_key "system_prompts", "users"
  add_foreign_key "system_prompts", "users"
end
