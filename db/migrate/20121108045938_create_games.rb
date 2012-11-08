class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text :letters
      t.text :words
      t.integer :player_a_id
      t.integer :player_b_id
      t.integer :state, :default => 0
      t.integer :player_a_score, :default => 0
      t.integer :player_b_score, :default => 0

      t.timestamps
    end
  end
end
