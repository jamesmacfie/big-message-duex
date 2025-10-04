class CreateMentions < ActiveRecord::Migration[7.2]
  def change
    create_table :mentions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end

    add_index :mentions, [ :message_id, :person_id ], unique: true
  end
end
