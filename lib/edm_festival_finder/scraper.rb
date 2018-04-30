require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative '../edm_festival_finder'

class EdmFestivalFinder::Scraper

  def scrape_countries
    url = "http://www.electronic-festivals.com"
    doc = Nokogiri::HTML(open(url))
    country_hash = {}
    doc.css(".location_auto_country option").each do |country|
      country_hash["#{country.text.to_sym}"]=country.attribute("value").value
    end
    country_hash
  end

  def scrape_festivals(country_code, start_date, end_date)
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
    binding.pry
      array_of_festivals
  end


  def scrape_individual_festivals(festival)
    doc = Nokogiri::HTML(open("#{festival.individual_page}"))
    festival.environment = doc.css("col-xs-auto.col-sm-auto.nopadding.disc").text,
    festival.type_of_event = doc.css(".col-xs-auto.col-sm-auto.nopadding.nomarginright.disc").text,
    festival.link = doc.css(".col-xs-12.nopadding.eventlinks.link a").attribute("href").value,
    festival.facebook = doc.css(".col-xs-12.nopadding.link").attribute("href").value
  end

end

puts EdmFestivalFinder::Scraper.new.scrape_festivals("us", Date.today.to_s.gsub("-",""), Date.today.next_year.to_s.gsub("-",""))
