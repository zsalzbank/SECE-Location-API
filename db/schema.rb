# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121122051439) do

  create_table "areas", :force => true do |t|
    t.string   "name",                                                                                        :null => false
    t.float    "altitude",                                                                 :default => 0.0
    t.boolean  "circle",                                                                   :default => false
    t.spatial  "center",     :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.float    "radius"
    t.spatial  "shape",      :limit => {:srid=>4326, :type=>"polygon", :geographic=>true}
    t.datetime "created_at",                                                                                  :null => false
    t.datetime "updated_at",                                                                                  :null => false
    t.string   "slug"
    t.integer  "parent"
  end

  add_index "areas", ["slug"], :name => "index_areas_on_slug"

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.spatial  "location",   :limit => {:srid=>4326, :type=>"point", :geographic=>true},                  :null => false
    t.float    "altitude",                                                               :default => 0.0
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.float    "bearing",                                                                :default => 0.0
  end

  create_table "overlays", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.spatial  "geoRefA",          :limit => {:srid=>4326, :type=>"point", :geographic=>true},                  :null => false
    t.spatial  "geoRefB",          :limit => {:srid=>4326, :type=>"point", :geographic=>true},                  :null => false
    t.integer  "imgRefAX",                                                                                      :null => false
    t.integer  "imgRefAY",                                                                                      :null => false
    t.integer  "imgRefBX",                                                                                      :null => false
    t.integer  "imgRefBY",                                                                                      :null => false
    t.float    "altitude",                                                                     :default => 0.0
    t.string   "img_file_name"
    t.string   "img_content_type"
    t.integer  "img_file_size"
    t.datetime "img_updated_at"
    t.datetime "created_at",                                                                                    :null => false
    t.datetime "updated_at",                                                                                    :null => false
  end

end
