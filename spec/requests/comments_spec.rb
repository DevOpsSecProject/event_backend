require 'rails_helper'

RSpec.describe "Comments", type: :request do
  # Test data setup in FactoryBot
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:valid_attributes) {
    { content: "Lovely event", user_id: user.id }
  }
  # For empty comment validation fails
  let(:invalid_attributes) {
    { comment: { content: "", user_id: user.id } }
  }

  describe "GET /index" do
    it "renders a successful response" do
      create(:comment, user: user, event: event)
      # Get the list of comments for events
      get event_comments_path(event), as: :json
      expect(response).to be_successful
    end

    it "renders a successful response" do
      comment = create(:comment, user: user, event: event)
      other_event = create(:event)
      other_comment = create(:comment, user: user, event: other_event)
      # Request comment only for main event
      get event_comments_url(event), as: :json
      json_response = JSON.parse(response.body)
      # Filtering only when one comment is returned
      expect(response).to be_successful
      expect(json_response.length).to eq(1)
      expect(json_response.first['id']).to eq(comment.id)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      comment = create(:comment, user: user, event: event)
      # For specific comments
      get comment_path(comment), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Comment" do
        # Verify record exists and is created in the database
        expect {
          post event_comments_path(event), params: { comment: valid_attributes }, as: :json
        }.to change(Comment, :count).by(1)
      end

      it "renders a JSON response with the new comment" do
        post event_comments_path(event), params: { comment: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      context "with non existing user_id" do
        # Generate a user id that doesn't exist
        let(:new_user_id) { User.maximum(:id).to_i+ 1 }
        let(:new_event_attributes) {
          { comment: { content: "Great events", user_id: new_user_id } }
        }
        it "creates a new User and Comment" do
          # verify new user is automatically created when anon-existent user id is present
          # Can handle anonymous and new users
          expect {
            post event_comments_url(event), params: new_event_attributes, as: :json
          }.to change(User, :count).by(1)
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new comment" do
        expect {
          post event_comments_path(event), params: { comment: invalid_attributes }, as: :json
        }.to change(Comment, :count).by(0)
      end

      it "renders a JSON response with errors for the new comment" do
        # create request with invalid parameters
        post event_comments_path(event), params: { comment: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        # Create comment to update
        { comment: { content: "Updated comment" } }
      }

      it "updates the requested comment" do
        comment = create(:comment, user: user, event: event)
        patch comment_url(comment), params: new_attributes, as: :json
        comment.reload
        expect(comment.content).to eq("Updated comment")
      end

      it "renders a JSON response with the comment" do
        comment = create(:comment, user: user, event: event)
        # Make update request
        patch comment_url(comment), params: new_attributes, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the comment" do
        comment = create(:comment, user: user, event: event)
        # Make an update request with invalid parameters
        patch comment_path(comment), params: invalid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested comment" do
      comment = create(:comment, user: user, event: event)
      # verifying record is deleted from database
      expect {
        delete comment_path(comment), as: :json
      }.to change(Comment, :count).by(-1)
    end

    it "returns no content" do
      comment = create(:comment, user: user, event: event)
      # make a delete request
      delete comment_path(comment), as: :json
      expect(response).to have_http_status(:no_content)
    end
    # When deleting non existing comment
    context "when comment does not exist" do
      it "returns not found status code" do
        # Attempt to delete a comment with an ID that doesn't exist
        delete comment_path(id: 99999), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
