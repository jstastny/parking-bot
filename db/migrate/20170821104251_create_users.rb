class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :slack_id, index: true
      t.string :display_name

      t.timestamps
    end
  end
end
