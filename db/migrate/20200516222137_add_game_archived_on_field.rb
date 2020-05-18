class AddGameArchivedOnField < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :archived_on, :datetime
  end
end
