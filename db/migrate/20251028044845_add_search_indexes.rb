class AddSearchIndexes < ActiveRecord::Migration[7.2]
  def change
    # Add indexes for channel search
    # Note: PostgreSQL automatically optimizes ILIKE queries with these indexes
    add_index :channels, :name, opclass: :text_pattern_ops, where: "archived_at IS NULL"
    add_index :channels, :description, opclass: :text_pattern_ops, where: "archived_at IS NULL"

    # Add index for message content search
    add_index :messages, :content, opclass: :text_pattern_ops, where: "deleted_at IS NULL"

    # Add index for people name search (for DM searches)
    add_index :people, :name, opclass: :text_pattern_ops
  end
end
