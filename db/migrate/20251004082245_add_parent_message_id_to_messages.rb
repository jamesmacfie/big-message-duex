class AddParentMessageIdToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :parent_message_id, :bigint
    add_index :messages, :parent_message_id
    add_foreign_key :messages, :messages, column: :parent_message_id
  end
end
