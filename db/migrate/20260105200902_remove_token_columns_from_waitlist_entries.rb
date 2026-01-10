class RemoveTokenColumnsFromWaitlistEntries < ActiveRecord::Migration[8.1]
  def change
    remove_index :waitlist_entries, :confirmation_token
    remove_column :waitlist_entries, :confirmation_token, :string
    remove_column :waitlist_entries, :token_expires_at, :datetime
  end
end
