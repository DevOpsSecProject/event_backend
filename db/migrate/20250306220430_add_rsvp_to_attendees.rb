class AddRsvpToAttendees < ActiveRecord::Migration[8.0]
  def change
    add_column :attendees, :rsvp, :boolean
  end
end
