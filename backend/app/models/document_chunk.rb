class DocumentChunk < ApplicationRecord
  belongs_to :document

  has_neighbors :embedding

  validates :position, presence: true
  validates :content, presence: true
end
