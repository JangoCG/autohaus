class CreateWaitlistEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :waitlist_entries do |t|
      # Basis
      t.string :email, null: false
      t.string :confirmation_token, null: false

      # Anmeldung (Schritt 1) - Nachweis fur DSGVO/UWG
      t.string :signup_ip
      t.string :signup_user_agent
      t.text :consent_text

      # Bestatigung (Schritt 2) - Nachweis fur DSGVO/UWG
      t.datetime :confirmed_at
      t.string :confirmed_ip
      t.string :confirmed_user_agent

      # Token-Ablauf (24h)
      t.datetime :token_expires_at, null: false

      t.timestamps
    end

    add_index :waitlist_entries, :email, unique: true
    add_index :waitlist_entries, :confirmation_token, unique: true
  end
end
