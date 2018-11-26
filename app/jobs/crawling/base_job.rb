module Crawling
  class BaseJob < ::ApplicationJob
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
  end
end