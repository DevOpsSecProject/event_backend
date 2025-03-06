class AddDefaultValueToRsvp < ActiveRecord::Migration[6.1]
  def change
    change_column_default :attendees, :rsvp, false
  end
end
