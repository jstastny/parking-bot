class ReservationService
  class Error < StandardError;
  end

  class NoAvailableParkingSpots < Error;
  end


  def find_empty_lot(from, to)
    # ParkingSpot.joins(:)
  end

  def create_reservation(user_id, from, to, parking_spot_name: nil)
    ActiveRecord::Base.transaction do
      available_spots = ParkingSpot.available_spots(from, to)
      spot = if parking_spot_name
               available_spots.find_by(name: parking_spot_name)
             else
               available_spots.first
             end

      raise NoAvailableParkingSpots unless spot
      Reservation.create!(user_id: user_id, from: from, to: to, parking_spot: spot)
    end
  end

  def capacity(date)
    [
      Reservation.on_date(date),
      ParkingSpot.available_spots(date, date)
    ]
  end
end
