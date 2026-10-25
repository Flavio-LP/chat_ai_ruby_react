class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: true, foreign_key: true
      t.string :filename, null: false
      t.string :content_type, null: false
      t.bigint :byte_size, null: false
      t.string :status, null: false, default: "uploaded"
      t.text :extracted_text
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :documents, %i[user_id created_at]
    add_index :documents, :status
  end
end
