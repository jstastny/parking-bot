class AddParkingSpotDisplayName < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_spots, :display_name, :string
  end
end
