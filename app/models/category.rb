class Category < ApplicationRecord
  validates :keyword, presence: true
  validates :name,    presence: true
end
