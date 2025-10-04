class CreateFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :favorites do |t|
      t.references :person, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true

      t.timestamps
    end

    add_index :favorites, [:person_id, :channel_id], unique: true
  end
end
