Rails.application.routes.draw do
  # Routes for Events (CRUD)
  resources :events, only: [:index, :create, :update, :destroy] do
    # Nested routes for Attendees (CRUD)
    resources :attendees, only: [:index, :create, :update, :destroy]
  end

  # RSVP functionality (custom route for attendees)
  resources :attendees do
    member do
      post :rsvp
    end
  end
end
