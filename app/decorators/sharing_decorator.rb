module SharingDecorator
  Classify.all.each do |classify|
    classify_name = classify.name_en
    define_method classify_name do
      sharing_elements.joins(:classify).find_by(classifies: { name_en: classify_name}).try(:value)
    end
  end
end