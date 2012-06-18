class AddCreditsToSecSubMaps < ActiveRecord::Migration
  def change
  	#Default credits given as 1.
    add_column :sec_sub_maps, :credits, :integer, :default => 1
  end
end
