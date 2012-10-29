class CreateOverlays < ActiveRecord::Migration
  def change
    create_table :overlays do |t|
      t.string :name
      t.text :description
      t.point :geoRefA, :null => false, :geographic => true
      t.point :geoRefB, :null => false, :geographic => true
      t.integer :imgRefAX, :null => false
      t.integer :imgRefAY, :null => false
      t.integer :imgRefBX, :null => false
      t.integer :imgRefBY, :null => false
      t.float :altitude, :default => 0
      t.attachment :img

      t.timestamps
    end
  end
end
