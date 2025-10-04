class CreateInvites < ActiveRecord::Migration[7.2]
  def change
    create_table :invites do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.references :invited_by, null: false, foreign_key: { to_table: :people }
      t.datetime :accepted_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :invites, :email
    add_index :invites, :token, unique: true
    add_index :invites, :expires_at
  end
end
