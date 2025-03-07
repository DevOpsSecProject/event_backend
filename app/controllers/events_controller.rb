class EventsController < ApplicationController
  # Before any action is executed, such as CRUD operations, find and set the associated event
  before_action :set_event, only: %i[ show update destroy ]

  # GET /events
  def index
    @events = Event.all

    render json: @events
  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      render json: @event, status: :created, location: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy!
  end

  private
  
    def set_event
      # Fetch the attendee id that belongs to the specific event
      @event = Event.find(params[:id])
    end    

  # Strong perameters to prevent mass assignment vulnerabilities
  def attendee_params
    def event_params
      # Only allow specific attributes to be updated
      params.expect(event: [ :title, :description, :date, :recurrence ])
    end
end
