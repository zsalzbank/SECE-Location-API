object false
node(:devices) { |d| partial('devices/show', :object => @devices) }
node(:area) { |a| partial('areas/show', :object => @area) }
