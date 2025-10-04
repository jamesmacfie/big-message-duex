class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :person, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.text :content
      t.datetime :edited_at

      t.timestamps
    end

    add_index :messages, [ :channel_id, :created_at ]
    add_index :messages, :edited_at
  end
end
