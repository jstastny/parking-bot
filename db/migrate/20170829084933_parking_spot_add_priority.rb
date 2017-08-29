class ParkingSpotAddPriority < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_spots, :priority, :integer
  end
end
