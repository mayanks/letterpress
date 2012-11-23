class CreateFbNotifies < ActiveRecord::Migration
  def change
    create_table :fb_notifies do |t|
      t.references :game
      t.references :user
      t.integer :state
      t.boolean :notified, :default => false
      t.integer :notification_status
      t.text :notification_response

      t.timestamps
    end
    add_index :fb_notifies, :game_id
    add_index :fb_notifies, :user_id
  end
end
