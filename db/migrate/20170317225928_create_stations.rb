class CreateStations < ActiveRecord::Migration[5.0]
	#what is the 5 on the end? research
  def change
  	create_table   :stations do |t|
  		t.string 	   :name
  		t.integer    :dock_count
  		t.date 			 :installation_date
  		# t.timestamps
      t.timestamps null: false
  	end
  end
end
