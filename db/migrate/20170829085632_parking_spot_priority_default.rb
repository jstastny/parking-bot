class ParkingSpotPriorityDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_null :parking_spots, :priority, false, 0
    change_column_default :parking_spots, :priority, from: nil, to: 0
  end
end
