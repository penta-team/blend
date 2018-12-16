class Sharing < ApplicationRecord
  belongs_to :site

  has_many :sharing_elements, dependent: :destroy

  validates :name, presence: true

  enum state: {
    closed: 0,
    opened: 1
  }

  def create_sharing_element(classify, value, dup = false)
    if dup
      sharing_element = sharing_elements.find_or_initialize_by classify: classify, value: value
      sharing_element.save!
    else
      sharing_element = sharing_elements.find_or_initialize_by classify: classify
      sharing_element.value = value
      sharing_element.save!
    end
  end
end
