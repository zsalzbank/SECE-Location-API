class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.point :location, :null => false, :geographic => true
      t.float :altitude, :default => 0

      t.timestamps
    end
  end
end
