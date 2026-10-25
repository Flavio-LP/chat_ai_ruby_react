class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false, default: ""
      t.string :status, null: false, default: "pending"
      t.string :llm_model_provider_id
      t.integer :input_tokens
      t.integer :output_tokens
      t.decimal :cost_usd, precision: 12, scale: 6
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :messages, %i[conversation_id created_at]
    add_index :messages, :status
  end
end
