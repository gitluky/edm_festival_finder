class EdmFestivalFinder::CLI

  attr_accessor :startdate, :enddate, :country_code, :festival_count, :festival_num

  def initialize #new instance sets the start date to the current date and end date a year from the current date
    self.startdate = Date.today.to_s
    self.enddate = Date.today.next_year.to_s
  end

  def call #puts out the landing screen and prompts user to press enter before listing the countrys
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

  def choose_country(no_results="")   #lists the countries
    country_hash = EdmFestivalFinder::Scraper.scrape_countries    #scrapes the list of countries from the site
    country_hash.each do    #displays the countries next to their country code
      |country,code| puts " #{code} - #{country}"
    end
    if block_given?
      yield(no_results)     #puts "No results found..." when get_festivals is called and there are no concerts found for the country"
    end
    puts "Enter the country code for the country of choice listed above or type 'back' or 'exit'"    #prompts user to enter country code
    self.country_code = gets.strip    #sets @country_code to input
    self.back_or_exit(self.country_code, 1)
    while country_hash.none? {|country,code| self.country_code == code}     #re-prompts if the country code until the country code is one from the list provided
      puts "Country code was not invalid, please re-enter."
      self.country_code = gets.strip    #resets @country_code to correct input
    end
    puts "Searching, please wait, this may take a minute."    #tells user to wait as the festivals are being retrieved by #get_festivals
    self.get_festivals
  end

  def no_results_found    #no results found message to yield in #choose_country
    "No results found for the country."
  end

  def get_festivals
    #scrapes the search results from searching the website with filters: @country_code, @startdate and @enddate
    search_results = EdmFestivalFinder::Scraper.scrape_festivals(self.country_code, self.startdate, self.enddate)
    if search_results == []
      self.choose_country(self.no_results_found) {|x| puts x}     #yields #no_results_found if scrape returns an empty array
    else
      EdmFestivalFinder::Festival.create_from_search(search_results)     #creates festivals from the array of festival hashes returned from the scrape
      EdmFestivalFinder::Festival.all.each do |festival|     #for each festival object, the instance variables are set from a hash created scraped from festival.individual_page
        festival.add_additional_details(EdmFestivalFinder::Scraper.scrape_individual_festivals(festival.individual_page))
      end
    end
    self.display_festivals
  end

  def display_festivals     #displays a numbered list of festivals and some details
    self.festival_count = 0
    EdmFestivalFinder::Festival.all.each do |festival|
      self.festival_count +=1
      puts "#{self.festival_count}. #{festival.name}"
      puts "  #{festival.country}, #{festival.startdate} - #{festival.enddate} (dd/mm/yy)"
    end
    self.choose_festival
  end

  def choose_festival
    #validates user input for festival selection by number, the number is then passed onto festival_details to be used as the EdmFestivalFinder::Festival.all index number
    #at this point user will be able to input back or exit
    puts "Enter the number for the festival to see more details or type 'back' or 'exit'"
    self.festival_num = gets.strip
    self.back_or_exit(self.festival_num, 2)
    while !self.festival_num.to_i.between?(1,self.festival_count)
      puts "Please re-enter the number, or type 'back' or 'exit'"
      self.festival_num = gets.strip
      self.back_or_exit(self.festival_num, 2)
    end
    self.festival_num = self.festival_num.to_i - 1
    self.festival_details
  end

  def festival_details    #puts out the festival instance variables of EdmFestivalFinder::Festival.all[@festival_num]
    puts ""
    puts "Name: #{EdmFestivalFinder::Festival.all[self.festival_num].name}"
    puts "Country: #{EdmFestivalFinder::Festival.all[self.festival_num].country}"
    puts "Date: #{EdmFestivalFinder::Festival.all[self.festival_num].startdate} - #{EdmFestivalFinder::Festival.all[self.festival_num].enddate}"
    puts "Confirmed acts: #{EdmFestivalFinder::Festival.all[self.festival_num].confirmed_acts}"
    puts "Attendance: #{EdmFestivalFinder::Festival.all[self.festival_num].attendance}"
    puts "Environment: #{EdmFestivalFinder::Festival.all[self.festival_num].environment}"
    puts "Type of event: #{EdmFestivalFinder::Festival.all[self.festival_num].type_of_event}"
    puts "Link: #{EdmFestivalFinder::Festival.all[self.festival_num].link}"
    puts "Facebook: #{EdmFestivalFinder::Festival.all[self.festival_num].facebook}"
    puts ""
    puts "Type 'back' to go to the festival list or 'exit'"
    input = gets.strip
    self.back_or_exit(input, 3)
  end

  def back_or_exit(input, go_to = 1)
    if input == 'back'
      if go_to == 1
        self.call
      elsif go_to == 2
        EdmFestivalFinder::Festival.reset_all
        choose_country
      elsif go_to == 3
        display_festivals
      end
    elsif input == 'exit'
      puts "Thank you for using EDM Festival Finder, Goodbye."
      exit
    end
  end

end
