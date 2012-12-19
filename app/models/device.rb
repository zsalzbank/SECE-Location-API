class Device < ActiveRecord::Base
  attr_accessible :name, :longitude, :latitude, :altitude, :bearing, :near_distance, :radius, :shape
  validates :name, :longitude, :latitude, :presence => true
  validates :longitude, :latitude, :numericality => true
  validates :near_distance, :numericality => true, :allow_nil => true
  validates :radius, :numericality => true, :allow_nil => true

  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326))
  set_rgeo_factory_for_column(:shape, RGeo::Geographic.spherical_factory(:srid => 4326))

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
    read_attribute(:near_distance) || self.generated_near_distance
  end

  def generated_near_distance
    if self.point?
      500
    else
      if self.circle?
        area = Math::PI * (self.radius ** 2)
      else
        area = self.connection.exec_query("SELECT ST_Area(shape) From devices where id=" + self.id.to_s).first()["st_area"]
      end

      2 * area.to_f
    end
  end

  def circle?
    self.radius != nil and self.shape == nil
  end

  def point?
    self.radius == nil and self.shape == nil
  end

  def shape_points
    if self.circle? or self.point?
      nil
    else
      self.shape.exterior_ring.points.map { |point| { :lat => point.latitude, :lng => point.longitude } }
    end
  end

  def self.DirectionAngles
    { "front" => 0, "left" => 270, "back" => 180, "right" => 90 }
  end

  def self.operator(device, ops = nil, buffer = 90, ref = nil)
    ops = [ ops ] unless ops.kind_of?(Array)
    buffer = 90 if buffer.blank?
    buffer = buffer.to_f
    ref = device if ref.blank?

    relation = clone
    ops.each do |o|
        if Device.DirectionAngles.has_key?(o)
            angle = ref.bearing + Device.DirectionAngles[o]

            relation = relation.where(angle_between("ST_Azimuth(ST_Centroid(#{device.obj}::geometry), location)", angle, buffer))
        elsif o == 'on'
            relation = relation.overlaps(device)
        elsif o == 'off'
            relation = relation.overlaps(device, false)
        else
            relation = relation.where(nil)
        end
    end
    relation
  end

  def obj
    center = "ST_GeographyFromText('#{self.location}')"

    if self.circle?
      obj = "ST_Buffer(#{center}, #{self.radius})"
    elsif self.point?
      obj = center
    else
      obj = "ST_GeographyFromText('#{self.shape}')"
    end

    obj
  end

  def self.overlaps(device, overlaps = true)
    circle_query = "(radius IS NOT NULL AND ST_Overlaps(ST_Buffer(location, radius)::geometry, #{device.obj}::geometry))"
    shape_query = "(shape IS NOT NULL AND ST_Overlaps(shape::geometry, #{device.obj}::geometry))"
    modifier = overlaps ? '' : 'NOT '

    where("(#{modifier}(#{circle_query} OR #{shape_query}))")
  end

  def self.max_distance(device, dist = nil)
    dist = device.near_distance if dist.blank?

    point_query = "(radius IS NULL AND shape IS NULL AND ST_DWithin(#{device.obj}, location, #{dist}))"
    circle_query = "(radius IS NOT NULL AND ST_DWithin(#{device.obj}, ST_Buffer(location, radius), #{dist}))"
    shape_query = "(shape IS NOT NULL AND ST_DWithin(#{device.obj}, shape, #{dist}))"

    where("(#{point_query} OR #{circle_query} OR #{shape_query})")
  end

  def self.altitude(alt = nil, buffer = 5)
    if alt.blank?
      where(nil)
    else
      alt = alt.to_f
      buffer = 5 if buffer.blank?
      buffer = buffer.to_f

      where("altitude BETWEEN #{alt - buffer} AND #{alt + buffer}")
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

  def self.in_area(area)
    point_query = "(devices.radius IS NULL AND devices.shape IS NULL AND " + Area.contains_query("devices.location", area) + ")"
    circle_query = "(devices.radius IS NOT NULL AND " + Area.contains_query("ST_Buffer(devices.location, devices.radius)", area) + ")"
    shape_query = "(devices.shape IS NOT NULL AND " + Area.contains_query("devices.shape", area) + ")"

    where("(#{point_query} OR #{circle_query} OR #{shape_query})")
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
