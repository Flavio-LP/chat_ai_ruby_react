class LlmModel < ApplicationRecord
  validates :provider_id, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
