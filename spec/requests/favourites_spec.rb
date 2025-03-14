require 'rails_helper'

RSpec.describe "Favourites", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:valid_attributes) { { user_id: user.id, event_id: event.id } }
  let(:invalid_attributes) { { user_id: nil, event_id: nil } }

  describe "GET /index" do
    it "renders a successful response" do
      create(:favourite, user_id: user.id, event: event)
      get favourites_url, as: :json
      expect(response).to be_successful
    end
  end
end
