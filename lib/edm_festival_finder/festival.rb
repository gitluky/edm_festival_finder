class EdmFestivalFinder::Festival
  @@all = []

  attr_accessor :name, :country, :startdate, :enddate, :environment, :attendance, :confirmed_acts, :type_of_event, :individual_page, :link, :facebook

  def create_from_search(array_of_festivals)
    array_of_festivals.each do |festival_hash|
      festival_hash.each do |attribute, value|
        self.send("#{attribute}=", value)
      end
    end
  end

  def add_additional_details(festival_detail_hash)
    festival_detail_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end


end
