class CreateDocumentChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_chunks do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :position, null: false
      t.text :content, null: false
      t.tsvector :tsv
      t.vector :embedding, limit: 384
      t.string :embedding_model

      t.timestamps
    end

    add_index :document_chunks, %i[document_id position]
    add_index :document_chunks, :tsv, using: :gin
  end
end
