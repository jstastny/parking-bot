class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.date :from, null: false
      t.date :to, null: false
      t.references :user, null: false, foreign_key: true, index: true
      t.references :parking_spot, null: false, foreign_key: true, index: true

      t.timestamps null: false
    end

    add_index :reservations, [:from, :to]
  end
end
