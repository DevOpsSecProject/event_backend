require 'rails_helper'

RSpec.describe "Favourites", type: :controller do
  let(:user) { create(:user)}
  let(:event) {create(:event)}
  let(:valid_attributes) {
    { favourite: { user_id: user.id, event_id: event.id } }
  }
  let(:invalid_attributes) {
    { favourite: { user_id: nil, event_id: nil} }
  }

  describe "GET /index" do
    it "renders a successful response" do
      create(:favourite, user: user, event: event)
      get favourites_url, as: :json
      expect(response).to be_successful
    end

    describe "GET /show" do
      it "renders a successful response" do
        favourite = create(:favourite, user: user, event: event)
        get favourite_url(favourite), as: :json
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Favourite" do
          expect {
            post favourites_url, params: { favourite: valid_attributes }, as: :json
          }.to change(Favourite, :count).by(1)
        end

        it "renders a JSON response with the new favourite" do
          post favourites_url, params: { favourite: valid_attributes }, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Favourite" do
          expect {
            post favourites_url, params: { favourite: invalid_attributes }, as: :json
          }.to change(Favourite, :count).by(0)
        end
        it "renders a JSON response with errors for the new favourite" do
          post favourites_url, params: { favourite: invalid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_user) { create(:user)}
        let(:new_attributes) {
          {favourite: { user_id: new_user.id} }
        }

        it "updates the requested favourite" do
          favourite = create(:favourite, user: user, event: event)
          patch favourite_url(favourite), params: { favourite: new_attributes }, as: :json
          favourite.reload
          expect(favourite.user_id).to eq(new_user.id)
        end

        it "renders a JSON response with the favourite" do
          favourite = create(:favourite, user: user, event: event)
          patch favourite_url(favourite), params: { favourite: new_attributes }, as: :json
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end

      context "with invalid parameters" do
        it "renders a JSON response with errors for the favourite" do
          favourite = create(:favourite, user: user, event: event)
          patch favourite_url(favourite), params: { favourite: invalid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested favourite" do
        favourite = create(:favourite, user: user, event: event)
        expect {
          delete favourite_url(favourite), as: :json
        }.to change(Favourite, :count).by(-1)
      end
    end
  end
end