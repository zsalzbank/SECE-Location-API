class DevicesController < ApplicationController
  def index
    relation = Device
    if params.has_key?(:id)
      device = Device.find_by_id(params[:id])
      if device
        relation = relation.direction(device, params[:operator], params[:operator_buffer])
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

    devices = Device.select("name, id, location").named_like(name)
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

#  def lookup
#    name = params[:name] || ""
#    location = params[:location] || ""
#    slugs = location.split('/').map { |l| l.parameterize }.reverse
#
#    if slugs.length > 0
#        devices = Device.where("devices.name ILIKE ? AND areas.slug ILIKE ?", name, slugs[0] + '%')
#                        .find(:all,
#                              :joins => "INNER JOIN areas ON " + Area.contains_query("devices.location"),
#                              :group => 'devices.id')
#        slugs.delete_at(0)
#    else
#        devices = Device.where("name ILIKE ?", name)
#    end
#    @devices = devices
#
#    amb = false
#
#    if devices.length <= 1
#        render 'devices/index'
#    else
#        if slugs.length > 0
#            while devices.length > 1 and slugs.length > 0
#                new_devices = []
#                devices.each do |d|
#                    new_devices.concat(
#                        Device.where("devices.id = ? AND areas.slug ILIKE ?", d.id, slugs[0] + '%')
#                              .find(:all,
#                                    :joins => "INNER JOIN areas ON " +
#                                               Area.contains_query("devices.location"),
#                                    :group => 'devices.id')
#                    )
#                end
#                slugs.delete_at(0)
#                devices = new_devices
#            end
#
#            @devices = devices
#            if devices.length <= 1
#                render 'devices/index'
#            else
#                amb = true
#            end
#        else 
#            amb = true
#        end
#    end
#
#    if amb 
#        results = []
#        devices.each do |d|
#            a = Area.select("id, name").contains_device(d).order_by_size().first()
#            results.append({ :device => d, :area => a })
#        end
#
#        render :json => {
#            :error => "Device name is ambiguous with the given location.",
#            :suggestions => results
#        } 
#    end
#  end
end
