class DevicesController < ApplicationController
  def index
    relation = Device
    if params.has_key?(:id)
      device = Device.find_by_id(params[:id])
      ref = Device.find_by_id(params[:ref]) if params.has_key?(:ref)
      if device
        relation = relation.operator(device, params[:operator], params[:operator_buffer], ref)
              .max_distance(device, params[:distance])
              .where("id != ?", device.id)
      else 
        @devices = []
        return
      end
    end

    relation = relation.altitude(params[:altitude], params[:altitude_buffer])
                       .named_like(params[:like])
                       .bearing(params[:bearing], params[:bearing_buffer])
    @devices = relation
  end

  def show
    @device = Device.find(params[:id])
  end

  def create
    @d = Device.new(params[:device])
    @d.shape = "POLYGON((" +params[:device][:shape].join(", ") + "))" if params[:device][:shape]
    render :json => { :success => @d.save, :errors => @d.errors }
  end

  def update
    @d = Device.find(params[:id])
    render :json => { :success => @d.update_attributes(params[:device]) }
  end

  def destroy
    @d = Device.find(params[:id])
    render :json => { :success => @d.destroy }
  end

  def lookup
    name = params[:name]
    devices = []
    areas = []

    area = Area.find_by_id(params[:aid]) if params[:aid]

    devices = Device.select("name, id, location, radius, shape").named_like(name)
    devices = devices.in_area(area) if area

    if devices.length > 1
        queries = []
        devices.each do |d|
            queries.append(Area.contains_device_query(d))
        end

        areas = Area.select("id, name").order_by_size("DESC")
        areas = areas.where(queries.join(" OR "))
        areas = areas.where("id <> ?", area.id) if area
    end

    render :json => {
        :devices => devices,
        :areas => areas
    }
  end
end
