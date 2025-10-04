class CreatePeople < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :is_agent, null: false, default: false
      t.text :agent_prompt
      t.string :theme, default: "light"

      t.timestamps
    end

    add_index :people, :is_agent
  end
end
