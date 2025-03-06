class Event < ApplicationRecord
    has_many :attendees, dependent: :destroy
    validates :title, presence: true
    validates :description, presence: true
    validates :date, presence: true
    validates :recurrence, inclusion: { in: ['daily', 'weekly', 'monthly'] }
  end
  