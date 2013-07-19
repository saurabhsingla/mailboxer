class AddLasttrashedatToConversations < ActiveRecord::Migration
  def up
  	add_column :conversations, :lasttrashed_at, :datetime
  end
  def down
  	remove_column :conversations, :fieldname
  end
end
