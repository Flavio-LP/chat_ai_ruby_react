class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :llm_model, null: true, foreign_key: true
      t.string :title, null: false, default: "Nova conversa"
      t.text :system_prompt_content
      t.text :summary
      t.integer :total_input_tokens, null: false, default: 0
      t.integer :total_output_tokens, null: false, default: 0
      t.decimal :total_cost_usd, null: false, default: 0, precision: 12, scale: 6
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :conversations, %i[user_id created_at]
  end
end
