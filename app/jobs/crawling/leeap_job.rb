module Crawling
  class LeeapJob < BaseJob
    def perform
      settings     = Settings.site.leeap
      current_time = Time.zone.now

      @site = find_or_create_site(
        settings.site_name,
        settings.root_url,
        settings.crawling_url,
        settings.category
      )

      agent = Mechanize.new
      page  = get_page(@site.crawling_url, agent)

      page.search(settings.selector.wrapper).each.with_index do |item, index|
        begin
          ActiveRecord::Base.transaction do
            type  = item.at(settings.selector.type).text
            image = item.at(settings.selector.image).attribute('src')&.value

            sharing            = @site.sharings.find_or_initialize_by name: "Leeap-#{index}"
            sharing.state      = :opened
            sharing.updated_at = current_time
            sharing.save!

            sharing.create_sharing_element sex_classify, "男性"
            sharing.create_sharing_element count_classify, "月１回交換可能"
            sharing.create_sharing_element plan_classify, type
            sharing.create_sharing_element image_classify, image
            if type == "カジュアルプラン"
              sharing.create_sharing_element price_classify, "7800円/月"
            elsif type == "ジャケパンプラン"
              sharing.create_sharing_element price_classify, "13800円/月"
            end
          end
        rescue => e
          Rails.logger.debug e
          Rails.logger.debug e.backtrace.join('\n')
          notify_exception e
          next
        end
      end

      @site.sharings.where.not(updated_at: current_time).update_all state: :closed
    end
  end
end
