# == Schema Information
#
# Table name: categories
#
#  id   :bigint(8)        not null, primary key
#  name :integer          not null
#

class Category < ApplicationRecord
  validates :name, presence: true

  has_many :sites
  has_many :category_classifies
  has_many :classifies, through: :category_classifies

  enum name: {
    car_share: 0,        # カーシェアリング
    bike: 1,             # 自転車
    parking: 2,          # 駐車場
    conference_room: 3,  # 会議室
    food_waste: 4,       # 廃棄食品シェア
    coworking: 5,        # コワーキング
    pet: 6,              # ペット
    child_care: 7,       # 子育て
    ride_sahre: 8,       # 相乗り
    taxi: 9,             # 個人タクシー
    guest_house: 10,     # 民泊
    clothes: 11,         # 服
    storage: 12,         # 物置
    bag: 13,             # バッグ
    watch: 14,           # 腕時計
    furniture: 15        # 家具
  }

  scope :with_site, -> { where id: joins(:sites) }
end
