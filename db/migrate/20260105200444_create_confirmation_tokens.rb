class CreateConfirmationTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :confirmation_tokens do |t|
      t.references :waitlist_entry, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.datetime :redeemed_at

      t.timestamps
    end

    add_index :confirmation_tokens, :code, unique: true
  end
end
