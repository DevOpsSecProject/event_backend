RSpec.describe User, type: :model do
  describe  'associations' do
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:favourites).dependent(:destroy) }
    it { should have_many(:tickets).dependent(:destroy) }

  end
end