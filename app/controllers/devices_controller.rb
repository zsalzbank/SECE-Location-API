class DevicesController < ApplicationController
  def index
    @devices = Device.all()
  end

  def show
    @device = Device.find(params[:id])
  end

  def create
    @d = Device.new(params[:device])
    render :json => { :success => @d.save }
  end

  def update
    @d = Device.find(params[:id])
    render :json => { :success => @d.update_attributes(params[:device]) }
  end

  def near
    @distance = params[:distance].to_f
    @location = Device.find(params[:id]).location.to_s
    @devices = Device.where("ST_Distance(location, ?) < ? AND id != ?", @location, @distance, params[:id])
    render 'index'
  end

  def destroy
    @d = Device.find(params[:id])
    render :json => { :success => @d.destroy }
  end
end
