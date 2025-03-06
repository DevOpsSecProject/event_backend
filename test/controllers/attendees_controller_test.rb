require "test_helper"

class AttendeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendee = attendees(:one)
  end

  test "should get index" do
    get attendees_url, as: :json
    assert_response :success
  end

  test "should create attendee" do
    assert_difference("Attendee.count") do
      post attendees_url, params: { attendee: { email: @attendee.email, event_id: @attendee.event_id, name: @attendee.name, rsvp: @attendee.rsvp } }, as: :json
    end

    assert_response :created
  end

  test "should show attendee" do
    get attendee_url(@attendee), as: :json
    assert_response :success
  end

  test "should update attendee" do
    patch attendee_url(@attendee), params: { attendee: { email: @attendee.email, event_id: @attendee.event_id, name: @attendee.name, rsvp: @attendee.rsvp } }, as: :json
    assert_response :success
  end

  test "should destroy attendee" do
    assert_difference("Attendee.count", -1) do
      delete attendee_url(@attendee), as: :json
    end

    assert_response :no_content
  end
end
