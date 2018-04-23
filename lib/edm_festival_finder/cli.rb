class EdmFestivalFinder::CLI

  attr_accessor :startdate, :enddate

  def initialize
    self.startdate = Date.today.to_s
    self.enddate = Date.today.next_year.to_s
  end

  def call
    puts "        _____) ______    __     __)"
    puts "     /       (, /    ) (, /|  /|"
    puts "    )__        /    /    / | / |"
    puts "   /         _/___ /_ ) /  |/  |_"
    puts "  (_____)  (_/___ /  (_/   FESTIVAL FINDER"
    puts ""
    puts "Electronic Festivals between #{EdmFestivalFinder::CLI.new.startdate} to #{EdmFestivalFinder::CLI.new.enddate}"
    puts ""
    puts "    [Press enter to choose country]"
    puts ""
  end

  def list_countries
    country_hash = EdmFestivalFinder::Scraper.scrape_countries
    country_hash.each do
      |country,code| puts " #{code} - #{country}"}
    end
  end

  def enter_country
    puts "Enter the country code for the country of choice listed above"
    country_code = gets.strip
    while country_hash.none? {|country,code| input == code}
      puts "Country code was not invalid, please re-enter."
      country_code = gets.strip
    end
    EdmFestivalFinder::Scraper.scrape_festivals(country_code)
  end

  def display_festivals
    i = 1
    EdmFestivalFinder::Festival.all.each do |festival|
      puts "{i}. #{festival.name}"
      puts "  #{festival.location}, #{festival.startdate} - #{festival.enddate}"
      i+=1
    end
    puts "Enter the number for the festival to see more details"

  end






end
