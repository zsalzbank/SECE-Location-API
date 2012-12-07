class AddRadiusAndShapeToDevice < ActiveRecord::Migration
  def up
    change_table :devices do |t|
      t.float :radius
      t.polygon :shape, :geographic => true, :srid => 4326
    end
  end

  def down
    remove_column :devices, :radius
    remove_column :devices, :shape

  end
end
