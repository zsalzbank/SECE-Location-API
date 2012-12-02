class Area < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :altitude, :center, :circle, :name, :radius, :shape
  friendly_id :name, :use => [:slugged, :scoped], :scope => :parent 
  has_many :children, :class_name => 'Area', :foreign_key => 'parent'
  belongs_to :parent, :class_name => 'Area', :foreign_key => 'parent'
  validates :center, :presence => true, :if => :circle?
  validates :radius, :presence => true, :if => :circle?
  validates :shape, :presence => true, :unless => :circle?

  set_rgeo_factory_for_column(
    :center,
    RGeo::Geographic.spherical_factory(:srid => 4326)
  )

  set_rgeo_factory_for_column(
    :shape,
    RGeo::Geographic.spherical_factory(:srid => 4326)
  )

  def should_generate_new_friendly_id?
    new_record? || name_changed? || parent_changed?
  end

  def center_point
    if self.circle
      { :lat => self.center.latitude, :lng => self.center.longitude }
    else
      nil
    end
  end

  def shape_points
    if self.circle
      nil
    else
      self.shape.exterior_ring.points.map { |point| { :lat => point.latitude, :lng => point.longitude } }
    end
  end

  def self.find_by_slugs(slugs)
    areas = Area.find_all_by_slug(slugs[0])
    slugs.delete_at(0)

    results = []
    areas.each do | a |
      slug = a
      slugs.each do | s |
        if slug.nil? || slug.parent.nil?
          a = nil
          break
        end
        slug = Area.where("id = ? and slug = ?", slug.parent.id, s).first()
      end
      a = nil if slug.nil?
      results.append(a)
    end

    results.delete_if { |x| x.nil? }
    results.uniq { |el| el.id }
    results
  end

  def self.contains_device(d)
    location = "ST_GeographyFromText('#{d.location}')"

    where(contains_query(location))
  end

  def self.contains_query(l)
    "(" +
    "(areas.circle IS FALSE AND ST_Intersects(areas.shape, #{l})) OR " +
    "(areas.circle IS TRUE AND ST_Intersects(ST_Buffer(areas.center, areas.radius), #{l}))" +
    ")"
  end

  def self.order_by_size(o = "ASC")
    select("(CASE WHEN areas.circle THEN (pow(areas.radius, 2) * pi()) ELSE ST_Area(shape) END) As area").order("area " + o)
  end
end
