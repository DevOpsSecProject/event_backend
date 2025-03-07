require "test_helper"

class FavouritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @favourite = favourites(:one)
  end

  test "should get index" do
    get favourites_url, as: :json
    assert_response :success
  end

  test "should create favourite" do
    assert_difference("Favourite.count") do
      post favourites_url, params: { favourite: { event_id: @favourite.event_id, user_id: @favourite.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show favourite" do
    get favourite_url(@favourite), as: :json
    assert_response :success
  end

  test "should update favourite" do
    patch favourite_url(@favourite), params: { favourite: { event_id: @favourite.event_id, user_id: @favourite.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy favourite" do
    assert_difference("Favourite.count", -1) do
      delete favourite_url(@favourite), as: :json
    end

    assert_response :no_content
  end
end
