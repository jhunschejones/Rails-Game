class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :title
      # description field is stored using ActionText and not on the model
      t.timestamps
    end
  end
end
