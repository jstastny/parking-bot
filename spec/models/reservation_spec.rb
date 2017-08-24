describe Reservation do

  describe '.on_date' do
    context 'multiple reservations' do
      let(:date) {Date.new(2017, 7, 5)}

      let(:user_1) { User.create!}
      let!(:lot_1) {ParkingSpot.create!(name: 'lot 1')}
      let!(:lot_2) {ParkingSpot.create!(name: 'lot 2')}

      let!(:reservation_1) { Reservation.create!(user: user_1, parking_spot: lot_1, from: Date.new(2017, 7, 2), to: Date.new(2017,7, 10)) }
      let!(:reservation_2) { Reservation.create!(user: user_1, parking_spot: lot_2, from: Date.new(2017, 7, 1), to: Date.new(2017,7, 5)) }

      it 'offers both reservations' do
        expect(Reservation.on_date(date)).to match_array [reservation_1, reservation_2]
      end
    end
  end
end