class CreateTurns < ActiveRecord::Migration[6.0]
  def change
    create_table :turns do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.references :game, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
