class AddParentAndSlugToArea < ActiveRecord::Migration
    def up
        remove_column :areas, :url_name

        change_table :areas do |t|
            t.string :slug
            t.integer :parent, :defualt => nil
        end

        add_index :areas, :slug
    end

    def down
        add_column :areas, :url_name, :string, :null => false
        remove_index :areas, :slug
        remove_column :areas, :slug
        remove_column :areas, :parent
    end
end
