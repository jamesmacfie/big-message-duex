class CreateMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :members do |t|
      t.references :person, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.datetime :last_viewed_at
      t.datetime :typing_at

      t.timestamps
    end

    add_index :members, [ :person_id, :channel_id ], unique: true
    add_index :members, :role
  end
end
