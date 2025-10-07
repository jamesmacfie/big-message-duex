class ChangeChannelNameToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :channels, :name, true
  end
end
