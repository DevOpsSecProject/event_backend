require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'assoications' do
    it { should belong_to(:user).optional }
    it { should belong_to(:event) }
  end

  describe 'validations' do
    it { should validate_presence_of(:price) }
  end
end

