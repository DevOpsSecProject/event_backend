require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should belong_to(:event) }
  end
  describe 'validations' do
    it { should validate_presence_of(:content) }
  end
end
