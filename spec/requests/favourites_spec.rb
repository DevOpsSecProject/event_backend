require 'rails_helper'

RSpec.describe "Favourites", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  # Valid attributes for creating a favourite
  let(:valid_attributes) { { user_id: user.id, event_id: event.id } }
  # Invalid attributes that should cause validation failures
  let(:invalid_attributes) { { user_id: nil, event_id: nil } }

  describe "GET /index" do
    it "renders a successful response" do
      create(:favourite, user_id: user.id, event: event)
      get favourites_url, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      # Create test favourite record
      favourite = create(:favourite, user_id: user.id, event: event)
      # Make the request to list all favourites
      get favourite_url(favourite), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Favourite" do
        # Verify a new record is created in database
        expect {
          post favourites_url, params: { favourite: valid_attributes }, as: :json
        }.to change(Favourite, :count).by(1)
      end

      it "renders a JSON response with the new favourite" do
        # Make request to create favourite
        post favourites_path, params: { favourite: valid_attributes }, as: :json
        # Verify that no record is create when invalid
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Favourite" do
        expect {
          post favourites_path, params: { favourite: invalid_attributes }, as: :json
        }.to change(Favourite, :count).by(0)
      end

      it "renders a JSON response with errors for the new favourite" do
        post favourites_path, params: { favourite: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { user_id: create(:user).id } }

      it "updates the requested favourite" do
        # Create favourite to update
        favourite = create(:favourite, user: user, event: event)
        # Make update request
        patch favourite_path(favourite), params: { favourite: new_attributes }, as: :json
        # Reload the record from the database and verify it was updated
        favourite.reload
        expect(favourite.user_id).to eq(new_attributes[:user_id])
      end

      it "renders a JSON response with the favourite" do
        favourite = create(:favourite, user: user, event: event)
        # Make update request
        patch favourite_path(favourite), params: { favourite: new_attributes }, as: :json
        # Verify JSON response
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the favourite" do
        favourite = create(:favourite, user: user, event: event)
        patch favourite_path(favourite), params: { favourite: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested favourite" do
      favourite = create(:favourite, user: user, event: event)
      # Verifies that record has been removed
      expect {
        delete favourite_path(favourite), as: :json
      }.to change(Favourite, :count).by(-1)
    end
  end
end
