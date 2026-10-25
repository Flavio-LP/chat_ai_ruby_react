class SystemPrompt < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 100 }
  validates :content, presence: true

  scope :defaults, -> { where(is_default: true) }
end
