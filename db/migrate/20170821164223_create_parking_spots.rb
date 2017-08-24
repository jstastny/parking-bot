class CreateParkingSpots < ActiveRecord::Migration[5.1]
  def change
    create_table :parking_spots do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
