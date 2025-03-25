require 'rails_helper'

# Test suite for Favourite model
RSpec.describe Favourite, type: :model do
  describe 'associations' do
    # Verifies favourite belongs to user
    it { should belong_to(:user) }
    # Verifies favorite belongs to event
    it { should belong_to(:event) }
  end

    describe 'validations' do
      let(:user) { create(:user) }
      let(:event) { create(:event) }

      # Test that user cannot favourite the same event twice
      it 'validates uniquness of user for each event' do
        # Create an initial favourite record
        create(:favourite, user: user, event: event)
        # Attempt to create duplicate favourite with the same user and event
        duplicate_favourite = build(:favourite, user: user, event: event)
        # The duplicate should be invalid
        expect(duplicate_favourite).not_to be_valid
        # Specifically it will generate an error on user attribute
        expect(duplicate_favourite.errors[:user]).to include("has already been taken")
      end
    end
end
