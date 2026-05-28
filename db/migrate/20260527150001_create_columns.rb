class CreateColumns < ActiveRecord::Migration[8.1]
  def change
    create_table :columns do |t|
      t.references :board, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.references :assigned_agent, null: true, foreign_key: { to_table: :agents }

      t.timestamps
    end

    add_index :columns, [ :board_id, :name ], unique: true
    add_index :columns, [ :board_id, :position ], unique: true
  end
end
