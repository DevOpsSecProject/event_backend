require 'rails_helper'

RSpec.describe "Tickets", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:valid_attributes) {
    { ticket: { price: 100.00, seat_number: "A1", user_id: user.id, event_id: event.id } }
  }
  let(:invalid_attributes) {
    { ticket: { price: nil, event_id: event.id } }
  }

  describe "GET /index" do
    context "without event_id parameter" do
      it "returns all tickets" do
        create(:ticket, user: user, event: event)
        get tickets_path, as: :json
        expect(response).to be_successful
      end
    end

    context "with event_id parameter" do
      it "returns only tickets for specified events" do
        ticket = create(:ticket, user: user, event: event)
        other_event = create(:event)
        other_ticket = create(:ticket, event: other_event)

        get event_tickets_url(event), as: :json
        json_response = JSON.parse(response.body)

        expect(response).to be_successful
        expect(json_response.length).to eq(1)
        expect(json_response.first['id']).to eq(ticket.id)
      end
    end
  end

  describe "GET /show" do
    it "returns a successful response" do
      ticket = create(:ticket, user: user, event: event)
      get ticket_path(ticket), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new ticket" do
        expect {
          post ticket_path, params: valid_attributes, as: :json
        }.to change(Ticket, :count).by(1)
      end

      it "renders a JSON response with the new ticket" do
        post ticket_path, params: valid_attributes, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context "with invalid parameters" do
      it "does not create a new ticket" do
        expect {
          post ticket_path, params: invalid_attributes, as: :json
        }.to change(Ticket, :count).by(0)
      end

      it "renders a JSON response with errors for the new ticket" do
        post ticket_path, params: invalid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { ticket: { price: 150.00, seat_number: "B2" } }
      }

      it "updates the requested ticket" do
        ticket = create(:ticket, user: user, event: event)
        patch ticket_path(ticket), params: new_attributes, as: :json
        ticket.reload
        expect(ticket.price).to eq(150.00)
        expect(ticket.seat_number).to eq("B2")
      end
      it "renders a JSON response with the ticket" do
        ticket = create(:ticket, user: user, event: event)
        patch ticket_path(ticket), params: new_attributes, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
    context "with invalid parameters" do
      it "renders a JSON response with errors for the ticket" do
        ticket = create(:ticket, user: user, event: event)
        patch ticket_path(ticket), params: invalid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested ticket" do
      ticket = create(:ticket, user: user, event: event)
      expect {
        delete ticket_path(ticket), as: :json
      }.to change(Ticket, :count).by(-1)
    end

    it "returns no content status" do
      ticket = create(:ticket, user: user, event: event)
      delete ticket_path(ticket), as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
