class Classify < ApplicationRecord
  has_many :category_classifies
  has_many :categories, through: :category_classifies

  validates :name,    presence: true
  validates :name_en, presence: true
end