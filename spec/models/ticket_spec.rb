require 'rails_helper'

# Test suite for ticket model
RSpec.describe Ticket, type: :model do
  describe 'assoications' do
    # Verifies that a ticket can belong to a user and is optional
    # Allowing tickets to exists before being purchased by a user
    it { should belong_to(:user).optional }
    # Every ticket is associated with a specified event, ticket must belong to an event
    it { should belong_to(:event) }
  end

  describe 'validations' do
    # Verifies ticket has a price
    it { should validate_presence_of(:price) }
  end
end
