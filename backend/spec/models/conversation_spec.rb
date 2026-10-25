require "rails_helper"

RSpec.describe Conversation do
  subject(:conversation) { build(:conversation) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(255) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:llm_model).optional }
  it { is_expected.to have_many(:messages).dependent(:destroy) }
end
