require 'rails_helper'

RSpec.describe Favourite, type: :model do
  describe 'associations' do
    it { should belong_to(:user)}
    it { should belong_to(:event)}
  end

    describe 'validations' do
      let(:user) { create(:user)}
      let(:event) { create(:event)}


      it 'validates uniquness of user for each event' do
        create(:favourite, user: user, event: event)
        duplicate_favourite = build(:favourite, user: user, event: event)

        expect(duplicate_favourite).not_to be_valid
        expect(duplicate_favourite.errors[:user]).to include("has already been taken")
      end
    end
end

