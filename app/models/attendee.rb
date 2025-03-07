class Attendee < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :event_id }
  validates :rsvp, inclusion: { in: [true, false] }
end
