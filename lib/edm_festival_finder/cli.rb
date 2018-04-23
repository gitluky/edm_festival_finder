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
    self.choose_country
    self.get_festivals
    self.display_festivals
    self.choose_festivals
    self.festival_details
  end

  def choose_country
    country_hash = EdmFestivalFinder::Scraper.scrape_countries
    country_hash.each do
      |country,code| puts " #{code} - #{country}"}
    end
    puts "Enter the country code for the country of choice listed above"
    self.country_code = gets.strip
    while country_hash.none? {|country,code| input == code}
      puts "Country code was not invalid, please re-enter."
      self.country_code = gets.strip
    end
  end

  def get_festivals
    EdmFestivalFinder::Festival.create_from_search(EdmFestivalFinder::Scraper.scrape_festivals(self.country_code))
    EdmFestivalFinder::Festival.add_additional_details(EdmFestivalFinder::Scraper.scrape_individual_festivals(self.country_code))
    self.display_festivals
  end

  def display_festivals
    self.festival_count = 0
    EdmFestivalFinder::Festival.all.each do |festival|
      self.festival_count +=1
      puts "{i}. #{festival.name}"
      puts "  #{festival.location}, #{festival.startdate} - #{festival.enddate}"
    end
  end

  def choose_festival
    puts "Enter the number for the festival to see more details or type 'back' or 'exit'"
    self.festival_num = gets.strip
    while !input.between?(1,self.festival_count) || input != 'back' || input != 'exit'
      puts "Please re-enter the number, or type 'back' or 'exit'"
    end
    if input == 'back'
      EdmFestivalFinder::Festival.all.reset_all
      choose_country
    else
      puts "Thank you for using EDM Festival Finder, Goodbye."
    end
  end

  def festival_details
    puts "name: #{EdmFestivalFinder::Festival.all[self.festival_num].name}"
    puts "location: #{EdmFestivalFinder::Festival.all[self.festival_num].location}"
    puts "date: #{EdmFestivalFinder::Festival.all[self.festival_num].date}"
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
