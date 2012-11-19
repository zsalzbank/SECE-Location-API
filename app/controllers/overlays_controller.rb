class OverlaysController < ApplicationController
  def index
    @altitude = params[:altitude] || ""

    if @altitude != ""
      @altitude = @altitude.to_f
      @altitude = " AND altitude BETWEEN " + (@altitude - 5).to_s + " AND " + (@altitude + 5).to_s
    end

    @overlays = Overlay.where("1=1" + @altitude)
  end

  def show
    @overlay = Overlay.find(params[:id])
  end

  def create
    @o = Overlay.new(params[:overlay])
    render :json => { :success => @o.save }
  end

  def destroy
    @o = Overlay.find(params[:id])
    render :json => { :success => @o.destroy }
  end
end
