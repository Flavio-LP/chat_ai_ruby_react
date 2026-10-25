class Message < ApplicationRecord
  belongs_to :conversation

  ROLES = %w[user assistant system].freeze

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true, unless: -> { %w[pending streaming failed].include?(status) }
  validates :status, inclusion: { in: %w[pending streaming completed failed] }

  scope :for_context, ->(limit) { where(role: %w[user assistant], status: "completed").order(:created_at).last(limit) }
end
