module Crawling
  class NokisakiParkingJob < BaseJob
    def perform
      settings     = Settings.site.nokisaki_parking
      current_time = Time.zone.now

      @site = find_or_create_site(
        settings.site_name,
        settings.root_url,
        settings.crawling_url,
        settings.category
      )

      agent = Mechanize.new
      page  = get_page(@site.crawling_url, agent)

      page.search(settings.selector.first_select).each do |prefecture_item|
        prefecture_item_agent = Mechanize.new
        prefecture_item_page = get_page settings.root_url + prefecture_item['href'], prefecture_item_agent

        prefecture_item_page.search(settings.selector.second_select).each do |item|
          item_agent = Mechanize.new
          item_page = get_page settings.root_url + item['href'], item_agent

          item_page.search(settings.selector.third_select).each do |detail_item|
            begin
              ActiveRecord::Base.transaction do
                price = detail_item.at(settings.selector.price)&.text

                detail_agent = Mechanize.new
                detail_page  = get_page settings.root_url + detail_item['href'], detail_agent

                station_name = detail_page.at(settings.selector.station_name)&.text
                address      = detail_page.at(settings.selector.address)&.text
                image        = detail_page.at(settings.selector.image)&.get_attribute('src')
                # TODO: car_typeがうまく取得できない
                car_types    = detail_page.at(settings.selector.car_type)&.text&.split('/') || []

                sharing            = @site.sharings.find_or_initialize_by name: station_name
                sharing.state      = :opened
                sharing.updated_at = current_time
                sharing.link       = item_page.uri
                sharing.save!

                sharing.create_sharing_element price_classify, price
                sharing.create_sharing_element address_classify, address
                sharing.create_sharing_element image_classify, "https:" + image

                car_types.each do |car_type|
                  sharing.create_sharing_element car_type_classify, car_type.text, true
                end
              end
            rescue => e
              Rails.logger.debug e
              Rails.logger.debug e.backtrace.join('\n')
              notify_exception e
              next
            end
          end
        end
      end

      @site.sharings.where.not(updated_at: current_time).update_all state: :closed
    end
  end
end
