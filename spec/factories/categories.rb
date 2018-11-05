# == Schema Information
#
# Table name: categories
#
#  id   :bigint(8)        not null, primary key
#  name :integer          not null
#

FactoryBot.define do
  factory :category do
    name 0
  end
end
