namespace :crawling do
  def logger
    Rails.logger
  end

  desc "クローリングを行います"
  task run: :environment do
    Rails.logger = Logger.new Rails.root.join('log', "#{File.basename(__FILE__, '.*')}.log")

    agent = Mechanize.new
    page = agent.get("https://plus.timescar.jp/car/")
    puts page.search('title')
    car_types = page.search('#d_page > div.contents > section.main > div.main-wide > div.car > div.aboutcar > div.carlist > dl:nth-child(n) > dd > p.name > span')
    car_types.each do |car_type|
      puts car_type.text
    end

    links = page.search('#d_page > div.contents > section.main > div.main-wide > div.car > div.aboutcar > div.carlist > dl:nth-child(n) > div.car_bt_area > p.station-btn > a')
    links.each do |link|
      page_2 = page.link_with(href: link.get_attribute(:href)).click
      puts page_2.at('#d_search > h2').text
      while(page_2.at('#goNext'))
        stations = page_2.search('#stationNm, #adr1')
        stations.each do |station_name|
          puts station_name.text
        end
        page_2 = page_2.link_with(href: page_2.at('#goNext').get_attribute(:href)).click
      end
    end
  end
end