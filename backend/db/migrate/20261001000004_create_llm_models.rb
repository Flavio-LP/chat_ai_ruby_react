class CreateLlmModels < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_models do |t|
      t.string :provider_id, null: false
      t.string :name, null: false
      t.string :display_name
      t.decimal :input_price_per_million_tokens, precision: 12, scale: 6
      t.decimal :output_price_per_million_tokens, precision: 12, scale: 6
      t.integer :context_window
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :llm_models, :provider_id, unique: true
    add_index :llm_models, :active
  end
end
