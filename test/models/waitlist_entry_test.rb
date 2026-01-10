require "test_helper"

class WaitlistEntryTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    entry = WaitlistEntry.new(email: "new@example.com")
    assert entry.valid?
  end

  test "should require email" do
    entry = WaitlistEntry.new(email: nil)
    assert_not entry.valid?
    assert_includes entry.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    entry = WaitlistEntry.new(email: "invalid-email")
    assert_not entry.valid?
    assert_includes entry.errors[:email], "is invalid"
  end

  test "should require unique email" do
    existing = waitlist_entries(:unconfirmed)
    entry = WaitlistEntry.new(email: existing.email)
    assert_not entry.valid?
    assert_includes entry.errors[:email], "has already been taken"
  end

  test "email uniqueness should be case insensitive" do
    existing = waitlist_entries(:unconfirmed)
    entry = WaitlistEntry.new(email: existing.email.upcase)
    assert_not entry.valid?
  end

  # Callbacks
  test "should create confirmation token on create" do
    entry = WaitlistEntry.create!(email: "new@example.com")
    assert_not_nil entry.confirmation_token
    assert_not_nil entry.confirmation_token.code
    assert_match(/\A[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}\z/, entry.confirmation_token.code)
  end

  test "should set token expiry on create" do
    entry = WaitlistEntry.create!(email: "new@example.com")
    assert_not_nil entry.confirmation_token.expires_at
    assert entry.confirmation_token.expires_at > Time.current
    assert entry.confirmation_token.expires_at <= 25.hours.from_now
  end

  test "should set consent text on create" do
    entry = WaitlistEntry.new(email: "new@example.com")
    assert_nil entry.consent_text
    entry.save!
    assert_equal WaitlistEntry::CONSENT_TEXT, entry.consent_text
  end

  # Instance methods
  test "confirmed? returns true when confirmed_at is present" do
    confirmed = waitlist_entries(:confirmed)
    assert confirmed.confirmed?
  end

  test "confirmed? returns false when confirmed_at is nil" do
    unconfirmed = waitlist_entries(:unconfirmed)
    assert_not unconfirmed.confirmed?
  end

  test "token_expired? returns true when token is expired" do
    expired = waitlist_entries(:expired_token)
    assert expired.token_expired?
  end

  test "token_expired? returns false when token is still valid" do
    unconfirmed = waitlist_entries(:unconfirmed)
    assert_not unconfirmed.token_expired?
  end

  test "confirm! sets confirmation data" do
    entry = waitlist_entries(:unconfirmed)
    assert_nil entry.confirmed_at
    assert_nil entry.confirmed_ip
    assert_nil entry.confirmed_user_agent

    entry.confirm!(ip: "10.0.0.1", user_agent: "Test Agent")

    assert_not_nil entry.confirmed_at
    assert_equal "10.0.0.1", entry.confirmed_ip
    assert_equal "Test Agent", entry.confirmed_user_agent
    assert entry.confirmed?
  end

  test "regenerate_token! creates new token and expiry" do
    entry = waitlist_entries(:expired_token)
    old_code = entry.confirmation_token.code
    old_expiry = entry.confirmation_token.expires_at

    entry.regenerate_token!
    entry.confirmation_token.reload

    assert_not_equal old_code, entry.confirmation_token.code
    assert entry.confirmation_token.expires_at > old_expiry
    assert_not entry.token_expired?
  end

  # Scopes
  test "confirmed scope returns only confirmed entries" do
    confirmed_entries = WaitlistEntry.confirmed
    confirmed_entries.each do |entry|
      assert entry.confirmed?
    end
  end

  test "unconfirmed scope returns only unconfirmed entries" do
    unconfirmed_entries = WaitlistEntry.unconfirmed
    unconfirmed_entries.each do |entry|
      assert_not entry.confirmed?
    end
  end
end
