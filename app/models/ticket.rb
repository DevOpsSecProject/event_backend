class Ticket < ApplicationRecord
  belongs_to :user, optional: true # link to the user model
  belongs_to :event #Database link to events model
  validates :price, presence: true
end
