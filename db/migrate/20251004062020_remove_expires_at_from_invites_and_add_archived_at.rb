class RemoveExpiresAtFromInvitesAndAddArchivedAt < ActiveRecord::Migration[7.2]
  def change
    remove_column :invites, :expires_at, :datetime
    add_column :invites, :archived_at, :datetime
    add_index :invites, :archived_at
  end
end
