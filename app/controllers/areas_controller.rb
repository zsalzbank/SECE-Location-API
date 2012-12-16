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

  def within
    slugs = params[:slugs].split('/').reverse
    @areas = Area.find_by_slugs(slugs)

    if @areas.count != 1
      render :json => {:error => "Ambiguous or no area found."}
    else
      @area = @areas[0]
      @devices = Device.in_area(@area)
    end
  end

  def destroy
    @a = Area.find(params[:id])
    render :json => { :success => @a.destroy }
  end
end
