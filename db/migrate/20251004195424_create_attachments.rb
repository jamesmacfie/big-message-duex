class CreateAttachments < ActiveRecord::Migration[7.2]
  def change
    create_table :attachments do |t|
      t.references :message, null: false, foreign_key: true
      t.string :content_type
      t.bigint :file_size
      t.string :file_name

      t.timestamps
    end
  end
end
