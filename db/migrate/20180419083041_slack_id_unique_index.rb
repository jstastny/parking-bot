class SlackIdUniqueIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :slack_id
    add_index :users, :slack_id, unique: true
  end
end
