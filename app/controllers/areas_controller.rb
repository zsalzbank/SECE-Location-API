class AreasController < ApplicationController
  def create
    @a = Area.new()
    @a.name = params[:name]
    @a.url_name = params[:url_name]
    @a.altitude = params[:altitude]
    @a.circle = params[:circle]

    @a.center = "POINT(" + params[:center] + ")" if @a.circle
    @a.radius = params[:radius] if @a.circle
    @a.shape = "POLYGON((" +params[:shape].join(", ") + "))" if not @a.circle

    render :json => { :success => @a.save }
  end
end
