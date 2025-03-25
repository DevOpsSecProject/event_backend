RSpec.describe User, type: :model do
  describe 'associations' do
    # When the user is deleted their comments are also deleted
    it { should have_many(:comments).dependent(:destroy) }
    # When a user is deleted all their favourites are deleted
    it { should have_many(:favourites).dependent(:destroy) }
    # When a user deleted and all their tickets are deleted as well
    it { should have_many(:tickets).dependent(:destroy) }
  end
end
