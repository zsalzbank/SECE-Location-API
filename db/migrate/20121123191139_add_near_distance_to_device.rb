class AddNearDistanceToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :near_distance, :float, :default => nil
  end
end
