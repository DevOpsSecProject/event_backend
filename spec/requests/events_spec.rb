# @Reference https://guides.rubyonrails.org/testing.html?_gl=1*11et9am*_gcl_au*MTM3MDUyMjc5MC4xNzI4NjAyNzYx*_ga*NDQ2NDI4MjAxLjE3MTcwMjMzMjg.*_ga_MBTGG7KX5Y*MTcyOTg1NTQyNS4zNC4xLjE3Mjk4NTU5MTEuMTEuMC4xOTI2MjU5NjY2
# @Reference https://dev.to/kevinluo201/introduce-rspec-request-spec-4pbl
# @Reference https://medium.com/%40lukepierotti/setting-up-rspec-and-factory-bot-3bb2153fb909
# Imports the test helper module
require 'rails_helper'

RSpec.describe EventsController, type: :request do
  # create an event before running the tests using the event factory
  let!(:event) { create(:event) }
  # test for GET /events route to return all events
  describe "GET /events" do
    it "returns all events" do
      # sending a GET request to fetch all events
      get "/events"
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected response body to contain one event
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end
  # test for GET /events/:id route to return the details of a specific event
  describe "GET /events/:id" do
    it "returns the event details" do
      # sending a get request to fetch the event by its ID
      get "/events/#{event.id}"
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected the response body to include the event's title
      expect(JSON.parse(response.body)["title"]).to eq(event.title)
    end
  end
  # test for POST /events route to create a new event
  describe "POST /events" do
    it "creates a new event" do
      # defines the perameters for the new event
      event_params = { title: "New Event", description: "A test event", date: Date.today, location: "Online", recurrence: "weekly" }
      # sending a POST request to cretae the new event
      post "/events", params: { event: event_params }
      # expected rsposnse to be 201 status code created
      expect(response).to have_http_status(:created)
      # expected the response body to contain the correct event title
      expect(JSON.parse(response.body)["title"]).to eq("New Event")
    end
  end
  # test for PATCH /events/:id route to update an existing event
  describe "PATCH /events/:id" do
    it "updates the event" do
      # sending a PATCH request to update the event's title
      patch "/events/#{event.id}", params: { event: { title: "Updated Event" } }
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected the event's title in the database to be updated
      expect(event.reload.title).to eq("Updated Event")
    end
  end
  # test for DELETE /events/:id route to delete an event
  describe "DELETE /events/:id" do
    it "deletes the event" do
      expect {
        # sending a DELETE request to remove the event
        delete "/events/#{event.id}"
        # expected the number of events to decrease by 1
      }.to change(Event, :count).by(-1)
      # expected response to be 204 status code no content
      expect(response).to have_http_status(:no_content)
    end
  end
  # test for POST /events/:id/generate_tickets route to generate tickets for an event
  describe "POST /events/:id/generate_tickets" do
    it "generates tickets for an event" do
      # sending a POST request to generate tickets for the event
      post "/events/#{event.id}/generate_tickets"
      # expected response to be 200 status code ok
      expect(response).to have_http_status(:ok)
      # expected the response body to contain a success key with value of true
      expect(JSON.parse(response.body)["success"]).to be true
    end
  end
end
