class Category < ApplicationRecord
  validates :name, presence: true

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
    brand: 12,           # ブランド小物
    storage: 13          # 物置
  }
end
