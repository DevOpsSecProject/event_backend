require 'rails_helper'

RSpec.describe "Event, Comments, and Ticket Integration", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe "Event workflow" do
    it "creates an event with comments and tickets" do
      # User favourites event
      post favourite_path, params: { favourite: { user_id: user.id, event_id: event.id } }
      expect(response).to have_http_status(:created)
      favourite = JSON.parse(response.body)["id"]

      # User adds comment to event
      post event_comments_url(event), params: { comment: { content: "Looking forward to the event", user_id: user.id } }, as: :json
      expect(response).to have_http_status(:created)
      comment_id = JSON.parse(response.body)["id"]

      # Customer has ticket
      post ticket_url, params: { ticket: { price: 75.0, seat_number: "C5", user_id: user.id, event_id: event.id } }, as: :json
      expect(response).to have_http_status(:created)
      ticket_id = JSON.parse(response.body)["id"]

      # User updates their comment
      patch comment_path(comment_id), params: { comment: { content: "Can't wait for this event" } }, as: :json
      expect(response).to have_http_status(:ok)

      # retrieve all user favourites
      get favourite_path, as: :json
      expect(response).to be_successful
      favourites = JSON.parse(response.body)
      expect(favourites.any? { |fav| fav["id"] == favourite.id }).to be true

      # get all event comments
      get event_comments_url(event), as: :json
      expect(response).to be_successful
      comments = JSON.parse(response.body)
      expect(comments.all? { |comment| comment["id"] == comment_id }).to be true

      get event_ticket_url(event), as: :json
      expect(response).to be successful
      tickets = JSON.parse(response.body)
      expect(tickets.all? { |ticket| ticket["id"] == ticket_id }).to be true
    end
  end
end
