class EdmFestivalFinder::Festival
  @@all = []

  attr_accessor :name, :country, :startdate, :enddate, :environment, :attendance, :confirmed_acts, :type_of_event, :individual_page, :link, :facebook

  def initialize(festival_hash)#initializes with a hash, sets instance variables and adds self to @@all
    festival_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
    self.class.all << self
  end

  def self.create_from_search(array_of_festivals) #class constructor to take in an array of hashes and initialize a new festival object with each hash
    array_of_festivals.each do |festival_hash|
      EdmFestivalFinder::Festival.new(festival_hash)
    end
  end

  def add_additional_details(festival_detail_hash) #takes a hash as an argument and sets the instance variables
    festival_detail_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def self.all
    @@all
  end

  def self.reset_all
    self.all.clear
  end


end
