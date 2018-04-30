class EdmFestivalFinder::CLI

  attr_accessor :startdate, :enddate, :country_code, :festival_count, :festival_num

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
    input = gets.strip
    while input != "\n"
      input = gets.strip
    end
    choose_country
  end

  def choose_country
    country_hash = EdmFestivalFinder::Scraper.scrape_countries
    country_hash.each do
      |country,code| puts " #{code} - #{country}"
    end
    puts "Enter the country code for the country of choice listed above"
    self.country_code = gets.strip
    while country_hash.none? {|country,code| input == code}
      puts "Country code was not invalid, please re-enter."
      self.country_code = gets.strip
    end
    self.get_festivals
  end

  def get_festivals
    EdmFestivalFinder::Festival.create_from_search(EdmFestivalFinder::Scraper.scrape_festivals(self.country_code, self.startedate, self.enddate))
    if EdmFestivalFinder::Festival.all == []
      puts "No festivals found in the selected country."
      self.choose_country
    else
      EdmFestivalFinder::Festival.all.each do |festival|
        scrape_individual_festivals(festival.individual_page)
      end
    end
    self.display_festivals
  end

  def display_festivals
    self.festival_count = 0
    EdmFestivalFinder::Festival.all.each do |festival|
      self.festival_count +=1
      puts "{i}. #{festival.name}"
      puts "  #{festival.location}, #{festival.startdate} - #{festival.enddate}"
    end
    self.choose_festivals
  end

  def choose_festival
    puts "Enter the number for the festival to see more details or type 'back' or 'exit'"
    self.festival_num = gets.strip
    while !self.festival_num.between?(1,self.festival_count) || input != 'back' || input != 'exit'
      puts "Please re-enter the number, or type 'back' or 'exit'"
    end
    if self.festival_num == 'back'
      EdmFestivalFinder::Festival.all.reset_all
      choose_country
    elsif self.festival_num == 'exit'
      puts "Thank you for using EDM Festival Finder, Goodbye."
    else
      self.festival_num = self.festival_num.to_i - 1
    end
  end

  def festival_details
    puts "name: #{EdmFestivalFinder::Festival.all[self.festival_num].name}"
    puts "country: #{EdmFestivalFinder::Festival.all[self.festival_num].country}"
    puts "date: #{EdmFestivalFinder::Festival.all[self.festival_num].startdate} - #{EdmFestivalFinder::Festival.all[self.festival_num].enddate}"
    puts "confirmed acts: #{EdmFestivalFinder::Festival.all[self.festival_num].confirmed_acts}"
    puts "attendance: #{EdmFestivalFinder::Festival.all[self.festival_num].attendance}"
    puts "environment: #{EdmFestivalFinder::Festival.all[self.festival_num].environment}"
    puts "type of event: #{EdmFestivalFinder::Festival.all[self.festival_num].type_of_event}"
    puts "link #{EdmFestivalFinder::Festival.all[self.festival_num].link}"
    puts "facebook #{EdmFestivalFinder::Festival.all[self.festival_num].facebook}"
    puts ""
    puts "Type 'back' to go to the festival list or 'exit'"
    input = gets.strip
    while input != 'back' || 'exit'
      input = gets.strip
    end
    if input == 'back'
      display_festivals
    else
      EdmFestivalFinder::Festival.all.reset_all
      puts "Thank you for using EDM Festival Finder, Goodbye."
    end
  end

end
