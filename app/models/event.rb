class Event < ApplicationRecord
    has_many :attendees, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :tickets, dependent: :destroy
    validates :title, presence: true
    validates :description, presence: true
    validates :date, presence: true
    validates :recurrence, inclusion: { in: [ "daily", "weekly", "monthly" ] }
end
