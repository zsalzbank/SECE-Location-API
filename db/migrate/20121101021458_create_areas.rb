class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name, :null => false
      t.string :url_name, :null => false
      t.float :altitude, :default => 0
      t.boolean :circle, :default => false
      t.point :center, :geographic => true
      t.float :radius
      t.polygon :shape, :geographic => true

      t.timestamps
    end
  end
end
