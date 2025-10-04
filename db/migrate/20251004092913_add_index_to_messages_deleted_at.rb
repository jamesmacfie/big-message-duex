class AddIndexToMessagesDeletedAt < ActiveRecord::Migration[7.2]
  def change
    add_index :messages, :deleted_at
  end
end
