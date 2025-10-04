class CreateChannels < ActiveRecord::Migration[7.2]
  def change
    create_table :channels do |t|
      t.string :name, null: false
      t.text :description
      t.string :channel_type, null: false, default: "channel"
      t.boolean :is_private, null: false, default: false
      t.datetime :archived_at
      t.references :created_by, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end

    add_index :channels, :name
    add_index :channels, :channel_type
    add_index :channels, :archived_at
  end
end
