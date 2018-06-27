class EdmFestivalFinder::Scraper

  def self.scrape_countries    #scrapes and creates a hash { country: code, ...} from the dropdown list of countries on the website
    url = "http://www.electronic-festivals.com"
    doc = Nokogiri::HTML(open(url))
    country_hash = {}
    doc.css(".location_auto_country option").each do |country|
      country_hash[country.text.to_sym]=country.attribute("value").value
    end
    country_hash
  end

  def self.scrape_festivals(country_code, start_date, end_date)   #uses arguments as filters in the URL, creates an array and inserts hashes for each festival scraped from the search results on the page
    start_date = start_date.gsub("-","")
    end_date = end_date.gsub("-","")
    array_of_festivals = []
    url = "http://www.electronic-festivals.com/home/result?title=&field_genre_tags_tid=All&field_type_of_event_value=All&country=#{country_code}&date_filter%5Bmin%5D%5Bdate%5D=#{start_date[6..7]}%2F#{start_date[4..5]}%2F#{start_date[0..3]}&date_filter%5Bmax%5D%5Bdate%5D=#{end_date[6..7]}%2F#{end_date[4..5]}%2F#{end_date[0..3]}&field_visitors_value=All&field_age_value=All&field_festicket_shop_value=All"
    doc = Nokogiri::HTML(open(url))
    festival_blocks = doc.css(".views-row")

    festival_blocks.each do |festival|
      array_of_festivals << {
        name: festival.css("h3 a").text,
        country: festival.css(".country-name").text,
        startdate: festival.css(".date-display-start").text,
        enddate: festival.css(".date-display-end").text,
        individual_page: "http://www.electronic-festivals.com/#{festival.css('h3 a').attribute('href').value}",
        confirmed_acts: "#{festival.css(".col-xs-auto.col-sm-auto.nopadding.right.small").first.text.match(/\d+/)}",
        attendance: "#{festival.css(".col-xs-auto.col-sm-auto.nopadding.right.small.star").text.match(/\d+\s\d+/)}"
      }
    end
      array_of_festivals
  end


  def self.scrape_individual_festivals(individual_page)   #takes a festival's individual page URL, scrapes the page and creates a hash
    doc = Nokogiri::HTML(open("#{individual_page}"))
    if !doc.css(".col-xs-12.nopadding.eventlinks.link a").empty?
      link = doc.css(".col-xs-12.nopadding.eventlinks.link a").attribute("href").value
    elsif !doc.css(".col-xs-12.nopadding.promoterlinks.link a").empty?
      link = doc.css(".col-xs-12.nopadding.promoterlinks.link a").attribute("href").value
    else
      link = ""
    end
    festival_detail_hash = {
      environment: doc.css("col-xs-auto.col-sm-auto.nopadding.disc").text,
      type_of_event: doc.css(".col-xs-auto.col-sm-auto.nopadding.nomarginright.disc").text,
      link: link,
      facebook: doc.xpath("//div[contains(@class, 'col-xs-12 nopadding link')]/a[contains(@href,'facebook')]").first.text
    }
  end

end
