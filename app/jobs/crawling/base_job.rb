module Crawling
  class BaseJob < ::ApplicationJob
    CRAWLING_WAIT_TIME = 10

    def find_or_create_site(site_name, root_url, crawling_url, category)
      category = Category.find_by(name: category)
      category.sites.find_or_create_by(site_name: site_name) do |site|
        site.root_url     = root_url
        site.crawling_url = crawling_url
      end
    end

    Classify.all.each do |classify|
      define_method "#{classify.name_en}_classify" do
        Classify.find_by name_en: classify.name_en
      end
    end

    def get_page(url, agent = Mechanize.new)
      page = agent.get url
      sleep CRAWLING_WAIT_TIME
      page
    end

    def notify_exception(exception)
      ExceptionNotifier.notify_exception(exception, env: Rails.env)
    end
  end
end
