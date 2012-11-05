class AreasController < ApplicationController
  def index
    @areas = Area.all()
  end

  def show
    @area = Area.find(params[:id])
  end

  def create
    @a = Area.new()
    @a.name = params[:name]
    @a.altitude = params[:altitude]
    @a.circle = params[:circle]
    @a.parent = Area.find(params[:parent]) if params[:parent].to_i != -1 else nil

    @a.center = "POINT(" + params[:center] + ")" if @a.circle?
    @a.radius = params[:radius] if @a.circle?
    @a.shape = "POLYGON((" +params[:shape].join(", ") + "))" if not @a.circle?

    render :json => { :success => @a.save }
  end

  def near
    @distance = 5000 if not params.has_key?(:distance) else params[:distance].to_f

    if(params.has_key?(:id))
        @areas = []
    elsif(params.has_key?(:n) && params.has_key?(:s) && params.has_key?(:e) && params.has_key?(:w))
        @box = "Geography(ST_Transform(ST_SetSRID(ST_MakeBox2D(ST_MakePoint(" + params[:w] + ", " + params[:s] + "), ST_MakePoint(" +
            params[:e] + ", " + params[:n] + ")), 4326), 4326))"
        @areas = Area.where("(circle IS TRUE AND ST_DWithin(center, " + @box + ", ? + radius)) OR (circle IS NOT TRUE AND ST_DWithin(shape, " + @box + ", ?))", @distance, @distance)
    else
        @areas = []
    end

    render 'index'
  end

  def within
    slugs = params[:slugs].split('/').reverse
    @areas = Area.find_by_slugs(slugs)

    if @areas.count != 1
      render :json => {:error => "Ambiguous or no area found."}
    else
      @area = @areas[0]
      if @area.circle?
        @devices = Device.where("ST_Distance(location, ST_GeomFromText(?)) < ?", @area.center.to_s, @area.radius)
      else
        @devices = Device.where("ST_Intersects(location, ST_GeomFromText(?))", @area.shape.to_s)
      end
    end
  end
end
