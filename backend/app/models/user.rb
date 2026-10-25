class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :conversations, dependent: :destroy
  has_many :system_prompts, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, uniqueness: { case_sensitive: false }
end
