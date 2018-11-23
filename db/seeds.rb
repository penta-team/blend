# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# カテゴリー追加
Category.names.each do |key, _value|
  category = Category.find_or_initialize_by name: key
  category.save!
end

# ------------------------------------------------------------------------
# 種別の追加
# ------------------------------------------------------------------------
classify_seeds = [
  { name_en: :price,               name: "料金" },
  { name_en: :address,             name: "住所" },
  { name_en: :station,             name: "ステーション名" },
  { name_en: :car_type,            name: "車両タイプ" },
  { name_en: :car_model,           name: "車種" },
  { name_en: :ridabble_number,     name: "乗車可能人数" },
  { name_en: :image,               name: "画像" },
  { name_en: :seating_capacity,    name: "収容人数" },
  { name_en: :business_hours,      name: "営業時間" },
  { name_en: :plan,                name: "プラン" },
  { name_en: :dog_size,            name: "犬のサイズ" },
  { name_en: :breeding_experience, name: "飼育経験" },
  { name_en: :user_name,           name: "ユーザー名" },
  { name_en: :departed_place,      name: "出発地" },
  { name_en: :destination,         name: "目的地" },
  { name_en: :language,            name: "言語" },
  { name_en: :volunteer_time,      name: "ボランティア時間" },
  { name_en: :business_outline,    name: "業務内容" },
  { name_en: :need_stay_length,    name: "必要滞在日数" },
  { name_en: :service_name,        name: "サービス名" },
  { name_en: :sex,                 name: "性別" },
  { name_en: :bland_name,          name: "ブランド名" },
  { name_en: :bag_type,            name: "バッグタイプ" },
  { name_en: :product_name,        name: "商品名" },
  { name_en: :size,                name: "サイズ" },
  { name_en: :usage_period,        name: "利用期間" },
  { name_en: :box_price,           name: "ボックス料金" },
  { name_en: :box_size,            name: "ボックスサイズ" },
  { name_en: :deposit_shipping,    name: "預入送料" },
  { name_en: :photo_price,         name: "写真撮影料金" },
  { name_en: :datetime,            name: "日時" },
  { name_en: :number,              name: "人数" },
  { name_en: :count,               name: "回数" }
]

classify_seeds.each do |classify_seed|
  classify = Classify.find_or_initialize_by name_en: classify_seed[:name_en]
  classify.name = classify_seed[:name]
  classify.save! if classify.new_record?
end

# ------------------------------------------------------------------------
# category_classifyの追加
# ------------------------------------------------------------------------
category_classify_seeds = [
  { category: :car_share,       classifies: %i[price address station car_type car_model ridabble_number image] },
  { category: :bike,            classifies: %i[price address station] },
  { category: :parking,         classifies: %i[address car_type price image station] },
  { category: :conference_room, classifies: %i[address price seating_capacity image] },
  { category: :food_waste,      classifies: %i[address price image] },
  { category: :coworking,       classifies: %i[address price business_hours plan] },
  { category: :pet,             classifies: %i[address dog_size breeding_experience] },
  { category: :child_care,      classifies: %i[price user_name address image] },
  { category: :ride_sahre,      classifies: %i[departed_place destination price datetime] },
  { category: :taxi,            classifies: %i[departed_place destination price] },
  { category: :guest_house,     classifies: %i[number address price image] },
  { category: :clothes,         classifies: %i[price count image plan service_name sex] },
  { category: :storage,         classifies: %i[plan price box_price box_size deposit_shipping photo_price] },
  { category: :bag,             classifies: %i[price bland_name product_name image bag_type] },
  { category: :watch,           classifies: %i[price bland_name product_name image sex] },
  { category: :furniture,       classifies: %i[price product_name size usage_period image] }
]

category_classify_seeds.each do |category_classify_seed|
  category = Category.find_by(name: category_classify_seed[:category])
  if category.blank?
    puts "====================================== not found category '#{category_classify_seed[:category]}'"
    next
  end

  category_classify_seed[:classifies].each do |classify_name|
    classify = Classify.find_by name_en: classify_name
    if classify.blank?
      puts "====================================== not found classify '#{classify_name}'"
      next
    end

    category_classify = CategoryClassify.find_or_initialize_by category: category, classify: classify
    category_classify.save! if category_classify.new_record?
  end
end
