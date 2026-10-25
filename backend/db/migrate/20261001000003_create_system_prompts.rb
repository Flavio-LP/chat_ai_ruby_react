class CreateSystemPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :system_prompts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :content, null: false
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end

    add_index :system_prompts, %i[user_id is_default]
  end
end
