module Crawling
  class TimesCarPlusJob < BaseJob
    def perform
      settings = Settings.site.times_car_plus

      @site = find_or_create_site(
        settings.site_name,
        settings.root_url,
        settings.crawling_url,
        settings.category
      )

      agent = Mechanize.new
      page = get_page(@site.crawling_url, agent)

      # ベーシッククラスの場合
      basic_class_price = page.at(settings.selector.price.basic_class).text
      create_sharing settings, page, settings.selector.car_list.basic_class, basic_class_price

      # プレミアムクラスの場合
      premium_class_price = page.at(settings.selector.price.premium_class).text
      create_sharing settings, page, settings.selector.car_list.premium_class, premium_class_price
    end

    def create_sharing(settings, page, item_selector, price)
      items = page.search item_selector
      items.each do |item|
        begin
          ActiveRecord::Base.transaction do
            image = item.at(settings.selector.image)&.get_attribute('src')
            car_name = item.at(settings.selector.car_name)&.text
            ridable_number = item.at(settings.selector.ridable_number)&.text
            station_link_href = item.at(settings.selector.station_link)&.get_attribute('href')

            sharing = @site.sharings.new name: car_name
            sharing.save!
            sharing.create_sharing_element image_classify, settings.crawling_url + image
            sharing.create_sharing_element ridable_number_classify, ridable_number.slice(/\d+/)
            sharing.create_sharing_element price_classify, price

            station_agent = Mechanize.new
            station_page  = get_page(settings.root_url + station_link_href, station_agent)
            while(station_page.at('#' + settings.selector.station.paginate_link).present?)
              station_page.search('#d_search table.table_tx tr[height][width]').each do |station_item|
                station_name = station_item.at(settings.selector.station.name)
                station_address = station_item.at(settings.selector.station.address)

                sharing.create_sharing_element station_classify, station_address.text + ' ' + station_name.text, true
              end

              station_page = station_page.link_with(dom_id: settings.selector.station.paginate_link).click
              sleep CRAWLING_WAIT_TIME
            end
          end
        rescue => e
          Rails.logger.debug e
          Rails.logger.debug e.backtrace.join('\n')
          next
        end
      end
    end

    def get_page(url, agent = Mechanize.new)
      page = agent.get url
      sleep CRAWLING_WAIT_TIME
      page
    end
  end
end