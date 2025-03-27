class CommentsController < ApplicationController
  before_action :set_event, only: [ :index, :create ]
  before_action :set_comment, only: %i[ show update destroy ]

  # GET /comments
  #  Adding comment
  def index
    @comments = @event.comments
    render json: @comments
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    @comment = @event.comments.new(comment_params)
    if params[:comment][:user_id].present? && !User.exists?(id: params[:comment][:user_id])
      @comment.user = User.create!(id: params[:comment][:user_id])
    end
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    begin
      @comment = Comment.find(params[:id])
      @comment.destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Record not found" }, status: :not_found
    end
  end


  private

  def set_event
    @event = Event.find(params[:event_id])
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:content, :user_id, :event_id)
    end
end
