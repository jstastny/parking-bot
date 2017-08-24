describe ParkingSpot do

  describe '.available_spots' do
    context 'all partially taken' do
      let(:from) {Date.new(2017, 7, 1)}
      let(:to) {Date.new(2017, 7, 5)}

      let(:user_1) { User.create!}
      let!(:lot_1) {ParkingSpot.create!(name: 'lot 1')}
      let!(:lot_2) {ParkingSpot.create!(name: 'lot 2')}

      let!(:reservation_1) { Reservation.create!(user: user_1, parking_spot: lot_1, from: Date.new(2017, 7, 2), to: Date.new(2017,7, 10)) }

      it 'offers lot 2' do
        expect(ParkingSpot.available_spots(from, to)).to eq [lot_2]
      end
    end
  end
end