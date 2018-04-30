class EdmFestivalFinder::Festival
  @@all = []

  attr_accessor :name, :country, :startdate, :enddate, :environment, :attendance, :confirmed_acts, :type_of_event, :individual_page, :link, :facebook

  def initialize(festival_hash)
    festival_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
    self.class.all << self
  end

  def self.create_from_search(array_of_festivals)
    array_of_festivals.each do |festival_hash|
      EdmFestivalFinder::Festival.new(festival_hash)
    end
  end

  def add_additional_details(festival_detail_hash)
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
