Rails.application.routes.draw do
  resources :tickets
  resources :favourites
  resources :comments

  # Routes for Events (CRUD)
  resources :events, only: [ :index, :show, :create, :update, :destroy ] do
    # Nested routes for Attendees (CRUD)
    resources :attendees, only: [ :index, :create, :update, :destroy ] do
      member do
        patch :rsvp  # Change from post to patch for consistency
      end
    end
    resources :comments, only: [ :index, :create, :update, :destroy ]
    resources :tickets, only: [ :index, :create, :update, :destroy ]

    member do
      post :generate_tickets
    end
  end

  # Removing the standalone attendees RSVP route
  resources :users do
    resources :favourites, only: [ :index ]
  end

  resources :favourites, only: [ :create, :destroy ]
  resources :tickets, only: [ :update, :destroy ]
end
