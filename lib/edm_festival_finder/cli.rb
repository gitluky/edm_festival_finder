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
    input = gets
    until input == "\n"
      input = gets
    end
    self.choose_country
  end

  def choose_country(no_results="")
    country_hash = EdmFestivalFinder::Scraper.scrape_countries
    country_hash.each do
      |country,code| puts " #{code} - #{country}"
    end
    if block_given?
      yield(no_results)
    end
    puts "Enter the country code for the country of choice listed above"
    self.country_code = gets.strip
    while country_hash.none? {|country,code| self.country_code == code}
      puts "Country code was not invalid, please re-enter."
      self.country_code = gets.strip
    end
    puts "Searching, please wait, this may take a minute."
    self.get_festivals
  end

  def no_results_found
    "No results found for the country."
  end

  def get_festivals
    search_results = EdmFestivalFinder::Scraper.scrape_festivals(self.country_code, self.startdate, self.enddate)
    if search_results == []
      self.choose_country(self.no_results_found) {|x| puts x}
    else
      EdmFestivalFinder::Festival.create_from_search(search_results)
      EdmFestivalFinder::Festival.all.each do |festival|
        festival.add_additional_details(EdmFestivalFinder::Scraper.scrape_individual_festivals(festival.individual_page))
      end
    end
    self.display_festivals
  end

  def display_festivals
    self.festival_count = 0
    EdmFestivalFinder::Festival.all.each do |festival|
      self.festival_count +=1
      puts "#{self.festival_count}. #{festival.name}"
      puts "  #{festival.country}, #{festival.startdate} - #{festival.enddate} (dd/mm/yy)"
    end
    self.choose_festival
  end

  def choose_festival
    puts "Enter the number for the festival to see more details or type 'back' or 'exit'"
    self.festival_num = gets.strip
    while self.festival_num != 'back' && self.festival_num != 'exit'
      while !self.festival_num.to_i.between?(1,self.festival_count)
        puts "Please re-enter the number, or type 'back' or 'exit'"
        self.festival_num = gets.strip
      end
    end
    if self.festival_num == 'back'
      EdmFestivalFinder::Festival.reset_all
      choose_country
    elsif self.festival_num == 'exit'
      puts "Thank you for using EDM Festival Finder, Goodbye."
    else
      self.festival_num = self.festival_num.to_i - 1
      self.festival_details
    end
  end

  def festival_details
    puts ""
    puts "Name: #{EdmFestivalFinder::Festival.all[self.festival_num].name}"
    puts "Country: #{EdmFestivalFinder::Festival.all[self.festival_num].country}"
    puts "Date: #{EdmFestivalFinder::Festival.all[self.festival_num].startdate} - #{EdmFestivalFinder::Festival.all[self.festival_num].enddate}"
    puts "Confirmed acts: #{EdmFestivalFinder::Festival.all[self.festival_num].confirmed_acts}"
    puts "Attendance: #{EdmFestivalFinder::Festival.all[self.festival_num].attendance}"
    puts "Environment: #{EdmFestivalFinder::Festival.all[self.festival_num].environment}"
    puts "Type of event: #{EdmFestivalFinder::Festival.all[self.festival_num].type_of_event}"
    puts "Link #{EdmFestivalFinder::Festival.all[self.festival_num].link}"
    puts "Facebook #{EdmFestivalFinder::Festival.all[self.festival_num].facebook}"
    puts ""
    puts "Type 'back' to go to the festival list or 'exit'"
    input = gets.strip
    while input != 'back' && input != 'exit'
      input = gets.strip
    end
    if input == 'back'
      display_festivals
    else
      puts "Thank you for using EDM Festival Finder, Goodbye."
    end
  end

end
