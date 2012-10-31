class OverlaysController < ApplicationController
  def index
    @overlays = Overlay.all()
  end

  def show
    @overlay = Overlay.find(params[:id])
  end

  def create
    @o = Overlay.new(params[:overlay])
    render :json => { :success => @o.save }
  end
end
