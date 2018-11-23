class Site < ApplicationRecord
  belongs_to :category

  validates :site_name,    presence: true
  validates :root_url,     presence: true
  validates :crawling_url, presence: true
end