class Device < ActiveRecord::Base
  attr_accessible :name, :longitude, :latitude, :altitude, :bearing, :near_distance
  validates :name, :longitude, :latitude, :presence => true
  validates :longitude, :latitude, :numericality => true
  validates :near_distance, :numericality => true, :allow_nil => true

  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326))

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
    read_attribute(:near_distance) || 500
  end

  def self.DirectionAngles
    { "front" => 0, "left" => 270, "back" => 180, "right" => 90 }
  end

  def self.direction(device, ops = nil, buffer = 90)
    ops = [ ops ] unless ops.kind_of?(Array)
    buffer = 90 if buffer.blank?
    buffer = buffer.to_f

    relation = clone
    ops.each do |o|
        if Device.DirectionAngles.has_key?(o)
            angle = device.bearing + Device.DirectionAngles[o]
            location = "ST_GeographyFromText('#{device.location}')"

            relation = relation.where(angle_between("ST_Azimuth(#{location}, location)", angle, buffer))
        else
            relation = relation.where(nil)
        end
    end
    relation
  end

  def self.max_distance(device, dist = nil)
    location = "ST_GeographyFromText('#{device.location}')"
    dist = device.near_distance if dist.blank?

    where("ST_DWithin(#{location}, location, #{dist})")
  end

  def self.altitude(alt = nil, buffer = 5)
    if alt.blank?
      where(nil)
    else
      alt = alt.to_f
      buffer = 5 if buffer.blank?
      buffer = buffer.to_f

      where("altitude BETWEEN (#{alt - buffer} AND #{alt + buffer})")
    end
  end

  def self.named_like(name)
    if name.blank?
      where(nil)
    else
      where("name ILIKE ?", '%' + name + '%')
    end
  end

  def self.bearing(bearing, buffer)
    if bearing.blank?
      where(nil)
    else
      bearing = bearing.to_f
      buffer = 10 if buffer.blank?
      buffer = buffer.to_f

      where(angle_between("bearing", bearing, buffer))
    end
  end

  private
  def self.angle_between(var, angle, buffer)
    min_a = (angle - buffer) % 360
    min_a += 360 if min_a < 0
    max_a = (angle + buffer) % 360
    max_a += 360 if max_a < 0

    min_r = min_a * Math::PI/180
    max_r = max_a * Math::PI/180
    
    if max_a - min_a < 0
      "(#{var} >= #{min_r} OR " + 
      "#{var} <= #{max_r})"
    else
      "#{var} BETWEEN #{min_r} AND #{max_r}"
    end
  end
end
