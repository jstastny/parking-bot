class Reservation < ApplicationRecord
  belongs_to :parking_spot
  belongs_to :user

  scope :on_date, ->(date) {
    where('"from" <= ? and "to" >= ?', date, date)
  }
end
