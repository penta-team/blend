module Searcher
  class Sharing < Base
    FULL_MATCHING_CLASSIFIES = %i[station car_type ridable_number price sex bag_type bland_name].freeze

    def set_condition(conditions)
      @name = conditions[:name].presence || ''

      # classify
      @address        = conditions[:search_address].presence || ''
      @station        = conditions[:search_station].presence || ''
      @car_type       = conditions[:search_car_type].presence || ''
      @ridable_number = conditions[:search_ridable_number].presence || ''
      @price          = conditions[:search_price].presence || ''
      @sex            = conditions[:search_sex].presence || ''
      @bag_type       = conditions[:search_bag_type].presence || ''
      @bland_name     = conditions[:search_bland_name].presence || ''
    end

    def query
      @records = @records.joins(:sharing_elements)

      search_by_value :name, @name
      search_by_keywords_from_address
      FULL_MATCHING_CLASSIFIES.each do |classify_name|
        send "search_by_value_from_#{classify_name}"
      end
    end

    Classify.where(name_en: FULL_MATCHING_CLASSIFIES).each do |classify|
      define_method "search_by_value_from_#{classify.name_en}" do
        value_variable = "@#{classify.name_en}"
        value          = send value_variable
        return if value.blank?

        dup_records = @records.dup
        dup_records = dup_records.joins(:sharing_elements)
        record_ids  = dup_records.where(sharing_elements: { classify_id: classify.id, value: value }).pluck(:id)

        @records = @records.where id: record_ids
      end
    end

    def search_by_keywords_from_address
      return if @address.blank?

      classify = Classify.find_by name_en: :address
      @records = @records.joins(:sharing_elements).where(classify_id: classify.id).where("sharing_elements.value LIKE '%#{@address}%'")
    end
  end
end
