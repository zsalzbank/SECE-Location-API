object @device
attributes :id, :altitude, :description, :imgRefAX, :imgRefAY, :imgRefBX, :imgRefBY, :name, :geoRefA_latitude, :geoRefA_longitude, :geoRefB_latitude, :geoRefB_longitude

node :img do |device|
  device.img.url
end

