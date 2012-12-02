class DevicesController < ApplicationController
  def index
    @distance = params[:distance].to_f || 5000
    @altitude = params[:altitude] || ""

    if @altitude != ""
      @altitude = @altitude.to_f
      @altitude = " AND altitude BETWEEN " + (@altitude - 5).to_s + " AND " + (@altitude + 5).to_s
    end

    if params.has_key?(:id)
      @device = Device.find_by_id(params[:id])
      if @device
        @location = Device.find(params[:id]).location.to_s
        @devices = Device.where("ST_Distance(location, ?) < ? AND id != ?" + @altitude, @location, @distance, params[:id])
      else
        @devices = []
      end
    elsif(params.has_key?(:n) && params.has_key?(:s) && params.has_key?(:e) && params.has_key?(:w))
        @box = "Geography(ST_Transform(ST_SetSRID(ST_MakeBox2D(ST_MakePoint(" + params[:w] + ", " + params[:s] + "), ST_MakePoint(" + params[:e] + ", " + params[:n] + ")), 4326), 4326))"
        @devices = Device.where("ST_DWithin(location, " + @box + ", ?)" + @altitude, @distance)
    else
      @devices = Device.where("1=1" + @altitude)
    end
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

  def destroy
    @d = Device.find(params[:id])
    render :json => { :success => @d.destroy }
  end

  def lookup
    name = params[:name] || ""
    location = params[:location] || ""
    slugs = location.split('/').map { |l| l.parameterize }.reverse

    if slugs.length > 0
        devices = Device.where("devices.name ILIKE ? AND areas.slug ILIKE ?", name, slugs[0] + '%')
                        .find(:all,
                              :joins => "INNER JOIN areas ON " + Area.contains_query("devices.location"),
                              :group => 'devices.id')
        slugs.delete_at(0)
    else
        devices = Device.where("name ILIKE ?", name)
    end
    @devices = devices

    amb = false

    if devices.length <= 1
        render 'devices/index'
    else
        if slugs.length > 0
            while devices.length > 1 and slugs.length > 0
                new_devices = []
                devices.each do |d|
                    new_devices.concat(
                        Device.where("devices.id = ? AND areas.slug ILIKE ?", d.id, slugs[0] + '%')
                              .find(:all,
                                    :joins => "INNER JOIN areas ON " +
                                               Area.contains_query("devices.location"),
                                    :group => 'devices.id')
                    )
                end
                slugs.delete_at(0)
                devices = new_devices
            end

            @devices = devices
            if devices.length <= 1
                render 'devices/index'
            else
                amb = true
            end
        else 
            amb = true
        end
    end

    if amb 
        results = []
        devices.each do |d|
            a = Area.select("id, name").contains_device(d).order_by_size().first()
            results.append({ :device => d, :area => a })
        end

        render :json => {
            :error => "Device name is ambiguous with the given location.",
            :suggestions => results
        } 
    end

  end
end
