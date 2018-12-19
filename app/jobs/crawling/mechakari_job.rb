# JSを読み込まないといけないので一旦Pending
module Crawling
  class MechakariJob < BaseJob
    def perform
      settings     = Settings.site.mechakari
      current_time = Time.zone.now

      @site = find_or_create_site(
        settings.site_name,
        settings.root_url,
        settings.crawling_url,
        settings.category
      )

      agent = Mechanize.new
      page  = get_page(@site.crawling_url, agent)

      Rails.logger.debug page.body

      page.search(settings.selector.bland_list).each do |bland|
        bland_agent = Mechanize.new
        bland_page  = get_page @site.root_url + bland['href'], bland_agent

        bland_page.search(settings.selector.product).each do |product|
          begin
            ActiveRecord::Base.transaction do
              image      = product.at(settings.selector.image)&.attribute('style')&.value
              image_url  = image.scan(/url\((.+?)\);\z/)
              name       = product.at(settings.selector.name)&.text
              bland_name = product.at(settings.selector.bland_name)&.text

              sharing            = @site.sharings.find_or_initialize_by name: name
              sharing.state      = :opened
              sharing.updated_at = current_time
              sharing.save!

              sharing.create_sharing_element sex_classify, "女性"
              sharing.create_sharing_element bland_name_classify, bland_name
              sharing.create_sharing_element image_classify, image_url
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
  end
end
