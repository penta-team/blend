class Site < ApplicationRecord
  belongs_to :category

  validates :site_name,    presence: true
  validates :root_url,     presence: true
  validates :crawling_url, presence: true

  class << self
    def find_or_create_site()
  end
end