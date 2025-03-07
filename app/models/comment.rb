class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  validates :content, presence: true
end
