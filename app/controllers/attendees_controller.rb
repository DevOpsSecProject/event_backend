class AttendeesController < ApplicationController
  # Before any action is executed, find and set the associated event
  before_action :set_event
  # Before any action is executed, such as the CRUD operation, find and set the attendee
  before_action :set_attendee, only: [:update, :destroy, :rsvp]

  # GET /events/:event_id/attendees
  def index
    @attendees = @event.attendees.includes(:event)
    render json: @attendees, include: { event: { only: [:title, :description, :date, :recurrence] } }
  end

  # POST /events/:event_id/attendees
  def create
    @attendee = @event.attendees.new(attendee_params)
    @attendee.rsvp = false
    if @attendee.save
      render json: @attendee, status: :created
    else
      render json: @attendee.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/:event_id/attendees/:id
  def update
    if @attendee.update(attendee_params)
      render json: @attendee
    else
      render json: @attendee.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/:event_id/attendees/:id
  def destroy
    @attendee.destroy
    head :no_content
  end

  # PATCH /attendees/:id/rsvp
  def rsvp
    if @attendee.update(rsvp: params[:rsvp])
      render json: @attendee
    else
      render json: { error: 'Unable to update RSVP' }, status: :unprocessable_entity
    end
  end

  private
  # Finds the event based on the event_id perameter
  def set_event
    # Fetch the event using the provided event_id
    @event = Event.find(params[:event_id])
  end
  # Finds the attendee within the associated event
  def set_attendee
    # Fetch the attendee that belongs to the event
    @attendee = @event.attendees.find(params[:id])
  end
  # Strong perameters to prevent mass assignment vulnerabilities
  def attendee_params
    # Only allow specific attributes to be updated
    params.require(:attendee).permit(:name, :email, :rsvp)
  end
end
