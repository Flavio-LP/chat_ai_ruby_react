require "rails_helper"

RSpec.describe User do
  subject(:user) { build(:user) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it { is_expected.to have_many(:conversations).dependent(:destroy) }
  it { is_expected.to have_many(:system_prompts).dependent(:destroy) }
  it { is_expected.to have_many(:documents).dependent(:destroy) }
end
