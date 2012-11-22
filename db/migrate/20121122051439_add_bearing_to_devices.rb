class AddBearingToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :bearing, :float, :default => 0
  end
end
