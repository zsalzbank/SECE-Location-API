class Device < ActiveRecord::Base
  attr_accessible :name, :longitude, :latitude, :altitude, :bearing, :near_distance
  validates :name, :longitude, :latitude, :presence => true
  validates :longitude, :latitude, :numericality => true
  validates :near_distance, :numericality => true, :allow_nil => true

  set_rgeo_factory_for_column(
    :location,
    RGeo::Geographic.spherical_factory(:srid => 4326)
  )

  def longitude
    self.location.longitude
  end

  def longitude=(num)
    self.location = "POINT(0 0)" if self.location.nil?

    location_will_change!
    self.location = "POINT(" + num.to_s + " " + self.location.latitude.to_s + ")"
  end

  def latitude
    self.location.latitude
  end

  def latitude=(num)
    self.location = "POINT(0 0)" if self.location.nil?

    location_will_change!
    self.location = "POINT(" + self.location.longitude.to_s + " " + num.to_s + ")"
  end

  def near_distance
    read_attribute(:near_distance) || 50
  end
end
