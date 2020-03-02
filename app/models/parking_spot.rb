class ParkingSpot < ApplicationRecord
  has_many :reservations

  scope :available_spots, ->(from, to) {
    where('NOT EXISTS (SELECT * FROM reservations WHERE "from" <= ? and "to" >= ? and parking_spot_id = parking_spots.id)', to, from).order(priority: :desc)
  }

  def spot_display_name
    display_name || name
  end
end
