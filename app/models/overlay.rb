class Overlay < ActiveRecord::Base
  attr_accessible :altitude, :description, :geoRefA, :geoRefB, :imgRefAX, :imgRefAY, :imgRefBX, :imgRefBY, :name, :img, :geoRefA_latitude, :geoRefA_longitude, :geoRefB_latitude, :geoRefB_longitude

  has_attached_file :img
  validates :geoRefA, :geoRefB, :imgRefAX, :imgRefAY, :imgRefBX, :imgRefBY, :presence => true
  validates :imgRefAX, :imgRefAY, :imgRefBX, :imgRefBY, :altitude, :numericality => true

  set_rgeo_factory_for_column(
    :geoRefA,
    RGeo::Geographic.spherical_factory(:srid => 4326)
  )

  set_rgeo_factory_for_column(
    :geoRefB,
    RGeo::Geographic.spherical_factory(:srid => 4326)
  )

  def geoRefA_longitude
    self.geoRefA.longitude
  end

  def geoRefA_longitude=(num)
    self.geoRefA = "POINT(0 0)" if self.geoRefA.nil?

    location_will_change!
    self.geoRefA = "POINT(" + num.to_s + " " + self.geoRefA.latitude.to_s + ")"
  end

  def geoRefA_latitude
    self.geoRefA.latitude
  end

  def geoRefA_latitude=(num)
    self.geoRefA = "POINT(0 0)" if self.geoRefA.nil?

    location_will_change!
    self.geoRefA = "POINT(" + self.geoRefA.longitude.to_s + " " + num.to_s + ")"
  end

  def geoRefB_longitude
    self.geoRefB.longitude
  end

  def geoRefB_longitude=(num)
    self.geoRefB = "POINT(0 0)" if self.geoRefB.nil?

    location_will_change!
    self.geoRefB = "POINT(" + num.to_s + " " + self.geoRefB.latitude.to_s + ")"
  end

  def geoRefB_latitude
    self.geoRefB.latitude
  end

  def geoRefB_latitude=(num)
    self.geoRefB = "POINT(0 0)" if self.geoRefB.nil?

    location_will_change!
    self.geoRefB = "POINT(" + self.geoRefB.longitude.to_s + " " + num.to_s + ")"
  end
end
