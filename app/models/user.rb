class User < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :tickets, dependent: :destroy # can't remove tickets
end
