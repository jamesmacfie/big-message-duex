class CreateReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :reactions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :emoji, null: false

      t.timestamps
    end

    add_index :reactions, [:message_id, :person_id, :emoji], unique: true
  end
end
