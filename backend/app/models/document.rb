class Document < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, optional: true
  has_many :document_chunks, dependent: :destroy
  has_one_attached :file

  ALLOWED_CONTENT_TYPES = %w[
    application/pdf
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  MAX_SIZE = 50.megabytes

  validates :filename, presence: true
  validates :content_type, inclusion: { in: ALLOWED_CONTENT_TYPES }
  validates :status, inclusion: { in: %w[uploaded processing ready failed] }
end
