class EventsController < ApplicationController
  # Before any action is executed, such as CRUD operations, find and set the associated event
  before_action :set_event, only: [ :show, :update, :destroy, :generate_tickets ]

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

  # To POST new tickets
  def generate_tickets
    count =  10 # default number of tickets generated
    base_price =  25.00 # base number of tickets generated

    generated_count = 0 # Counter for successfully created tickets
    # Generate the specified number of tickets
    count.to_i.times do |i|
      seat_row = (65 + (i / 10)).chr # ASCII e.g. 65 = 'A' e
      seat_number = "#{seat_row}#{(i % 10)+1}"
      # calculate premium price based on the row
      row_premium = (seat_row.ord - 65) * 5.00
      ticket_price = base_price + row_premium.to_f + row_premium
      # Create ticket with calculated price and seat number
      ticket = @event.tickets.create(
        price: ticket_price,
        seat_number: seat_number
      )
      # counter increments
      generated_count += 1 if ticket.persisted?
    end
    # Returned json payload of ticket generation
    render json: {
      success: true,
      message: " #{generated_count} tickets generated",
      ticket_count: @event.tickets.count
    }
  end
  private
  def set_event
    # Fetch the attendee id that belongs to the specific event
    @event = Event.find(params[:id])
  end

  # Strong parameters to prevent mass assignment vulnerabilities
  def attendee_params
    params.require(:attendee).permit(:name, :email, :rsvp)
  end

  def event_params
    # Only allow specific attributes to be updated
    params.require(:event).permit(:title, :description, :date, :location, :recurrence)
  end
end
