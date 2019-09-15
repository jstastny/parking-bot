class Reservation < ApplicationRecord
  belongs_to :parking_spot
  belongs_to :user

  scope :on_date, ->(date) {
    where(from: date, to: date)
  }
end
