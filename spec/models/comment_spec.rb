require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    # Comment assigned to users is optional
    it { should belong_to(:user).optional }
    # Every comment belongs to an event
    it { should belong_to(:event) }
  end
  # verifies comment must have content and prevents empty comments
  describe 'validations' do
    it { should validate_presence_of(:content) }
  end
end
