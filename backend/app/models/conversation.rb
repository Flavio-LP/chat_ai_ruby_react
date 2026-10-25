class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :llm_model, optional: true
  has_many :messages, -> { order(:created_at) }, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }

  enum :status, { active: "active", archived: "archived" }, default: :active
end
