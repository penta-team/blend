class Sharing < ApplicationRecord
  belongs_to :site

  has_many :sharing_elements, dependent: :destroy
  accepts_nested_attributes_for :sharing_elements, allow_destroy: true

  validates :name, presence: true
end