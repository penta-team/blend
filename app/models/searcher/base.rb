module Searcher
  class Base
    attr_accessor :table_name, :_records, :__records

    def initialize(conditions, records = nil)
      class_name = self.class.name.demodulize

      @table_name = class_name.underscore.pluralize
      @records    = records.nil? ? class_name.constantize.all : records

      set_condition conditions
    end

    def set_condition(conditions)
      raise NotImplementedError, "Must need to overriden `set_condition(Hash)` as instance method on #{self.class.name} class."
    end

    def query
      raise NotImplementedError, "Must need to overriden `query` as instance method on #{self.class.name} class."
    end

    def objects
      query
    end

    def search_by_value(column_name, value)
      if value.present?
        @records = @records.send :where, { column_name => value }
      end
    end

    def search_boolean(column_name, value)
      unless value.nil?
        @records = @records.send :where, { column_name => value }
      end
    end

    def search_by_datetime(column_name, start_at = '', end_at = '')
      if start_at.present? && end_at.present?
        cond = { column_name => start_at.beginning_of_day..end_at.end_of_day }
        @records = @records.send :where, cond
      elsif start_at.present?
        @records = @records.send :where, "#{column_name} >= ?", start_at.beginning_of_day
      elsif end_at.present?
        @records = @records.send :where, "#{column_name} <= ?", end_at.end_of_day
      end
    end

    def search_by_keywords(*args)
      keyword = args.pop
      return if keyword.blank?

      keyword.gsub! '　', ' '
      keywords = keyword.split ' '
      keywords = keywords[0, 4]

      columns = args

      assoc_type = @_table_name.singularize.classify

      keywords.each do |word|
        column_sqls = columns.map do |column_name|
          '`%s`.`%s` LIKE ?' % [@_table_name, column_name]
        end.join(' OR ')

        braces = columns.map{"%#{word}%"}
        @records = @records.send :where, [column_sqls, braces].flatten
      end
    end

    def convert_to_timeclass(at)
      return nil if at.blank?
      if at !~ /^(\d{4})-(\d{2})-(\d{2})$/
        return nil
      end
      Time.zone.local $1.to_i, $2.to_i, $3.to_i
    end

    def sorter_by_value(column_name, direction)
      column_name = column_name.to_s
      direction   = direction.to_s
      return if column_name.blank? || direction.blank?

      _model_name = self.class.name.gsub('Searcher', '').constantize
      direction = %w(asc desc).include?(direction) ? direction : "asc"

      if _model_name.column_names.include? column_name
        @records = @records.order(column_name + " " + direction)
      elsif _model_name.instance_methods(false).include? column_name.to_sym
        ids = if "asc" == direction
                @records.sort do |a, b|
                  a.send(column_name) <=> b.send(column_name)
                end
              elsif "desc" == direction
                @records.sort do |a, b|
                  b.send(column_name) <=> a.send(column_name)
                end
              end.map {|record| record.id}
        @records = @records.order(["field(id, ?)", ids])
      elsif column_name.include?(".") && block_given?
        model = column_name.split(".")[0]
        column = column_name.split(".")[1]
        yield(model, column, direction)
      elsif block_given?
        yield(column_name, direction)
      end
    end

    def searcher_dc(record)
      return record unless defined? ActiveDecorator::Decorator
      decorated = ActiveDecorator::Decorator.instance.decorate record
      decorated.presence || record
    end
  end
end
