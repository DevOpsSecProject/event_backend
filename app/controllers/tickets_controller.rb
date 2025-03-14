class TicketsController < ApplicationController
  before_action :set_event, only: [ :index, :create ]
  before_action :set_ticket, only: %i[ show update destroy ]

  # GET /tickets
  def index
    @tickets = @event ? @event.tickets : Ticket.all
    render json: @tickets
  end

  # GET /tickets/1
  def show
    render json: @ticket
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      render json: @ticket, status: :created
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/1
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/1
  def destroy
    @ticket.destroy!
    head :no_content
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:event_id]) if params[:event_id]
  end
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end
  # Only allow a list of trusted parameters through.
  def ticket_params
    params.require(:ticket).permit(:price, :seat_number, :user_id, :event_id)
  end
end
