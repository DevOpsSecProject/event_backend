# @Reference https://dev.to/kevinluo201/introduce-rspec-request-spec-4pbl
# @Reference https://medium.com/%40lukepierotti/setting-up-rspec-and-factory-bot-3bb2153fb909
# Imports the test helper module
require 'rails_helper'

RSpec.describe AttendeesController, type: :request do
  # create an event and an attendee before running the tests using the event factory
  let!(:event) { create(:event) }
  # create and attendee associated to the event
  let!(:attendee) { create(:attendee, event: event) }
  # test for GET /events/:event_id/attendees route to return all attendees for the specific event
  describe "GET /events/:event_id/attendees" do
    it "returns all attendees for an event" do
      # Get request to fetch attendees
      get "/events/#{event.id}/attendees"
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected the number of attendees to be 1
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end
  # test for POST /events/:event_id/attendees route to create a new attendee
  describe "POST /events/:event_id/attendees" do
    it "creates an attendee" do
      # defines the perameters for the new attendee
      attendee_params = { name: "Jane Doe", email: "jane@example.com", rsvp: false }
      # sends a post request to create the new attendee
      post "/events/#{event.id}/attendees", params: { attendee: attendee_params }
      # expected response to be 201 status code created
      expect(response).to have_http_status(:created)
      # expected response body to have the correct name for the attendee
      expect(JSON.parse(response.body)["name"]).to eq("Jane Doe")
    end
  end
  # test for PATCH /events/:event_id/attendees/:id route to update existing attendee
  describe "PATCH /events/:event_id/attendees/:id" do
    it "updates an attendee" do
      patch "/events/#{event.id}/attendees/#{attendee.id}", params: { attendee: { name: "Updated Name" } }
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expect the attendees name to be in the database
      expect(attendee.reload.name).to eq("Updated Name")
    end
  end
  # test for DELETE /events/:event_id/attendees/:id route to delete existing attendee
  describe "DELETE /events/:event_id/attendees/:id" do
    it "deletes an attendee" do
      expect {
        # sending a delete request to remove an attendee
        delete "/events/#{event.id}/attendees/#{attendee.id}"
        # expect the number of attendee to decrease by 1
      }.to change(Attendee, :count).by(-1)
      # expected response to be "no content" 204 status code
      expect(response).to have_http_status(:no_content)
    end
  end
  # test for PATCH /events/:event_id/attendees/:id route to update RSVP status of an attendee
  describe "PATCH /events/:event_id/attendees/:id/rsvp" do
    it "updates RSVP status" do
      # sending a patch request to update the RSVP status
      patch "/events/#{event.id}/attendees/#{attendee.id}/rsvp", params: { rsvp: true }
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected the attendee's RSVP status to be updated to true
      expect(attendee.reload.rsvp).to be true
    end
  end
end
