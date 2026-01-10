require "test_helper"

class ConfirmationTokenTest < ActiveSupport::TestCase
  test "generates code in Base58 XXXX-XXXX-XXXX format" do
    entry = WaitlistEntry.create!(email: "new@example.com")
    token = entry.confirmation_token

    assert token.code.present?
    parts = token.code.split("-")
    assert_equal 3, parts.count
    parts.each { |part| assert_equal 4, part.length }
  end

  test "redeem_if returns true and sets redeemed_at when block returns true" do
    token = confirmation_tokens(:unconfirmed_token)
    assert_nil token.redeemed_at

    result = token.redeem_if { true }

    assert result
    assert_not_nil token.reload.redeemed_at
  end

  test "redeem_if returns false when block returns false" do
    token = confirmation_tokens(:unconfirmed_token)

    result = token.redeem_if { false }

    assert_not result
    assert_nil token.reload.redeemed_at
  end

  test "redeem_if returns false for expired token" do
    token = confirmation_tokens(:expired_token)

    result = token.redeem_if { true }

    assert_not result
    assert_nil token.reload.redeemed_at
  end

  test "redeem_if returns false for already redeemed token" do
    token = confirmation_tokens(:confirmed_token)
    original_redeemed_at = token.redeemed_at

    result = token.redeem_if { true }

    assert_not result
    assert_equal original_redeemed_at, token.reload.redeemed_at
  end

  test "reset regenerates code and clears redeemed_at" do
    token = confirmation_tokens(:confirmed_token)
    original_code = token.code

    token.reset

    assert_not_equal original_code, token.code
    assert_nil token.redeemed_at
    assert token.expires_at > Time.current
  end

  test "active? returns true for unredeemed unexpired token" do
    token = confirmation_tokens(:unconfirmed_token)
    assert token.active?
  end

  test "active? returns false for expired token" do
    token = confirmation_tokens(:expired_token)
    assert_not token.active?
  end

  test "active? returns false for redeemed token" do
    token = confirmation_tokens(:confirmed_token)
    assert_not token.active?
  end

  test "expired? returns true for expired token" do
    token = confirmation_tokens(:expired_token)
    assert token.expired?
  end

  test "expired? returns false for unexpired token" do
    token = confirmation_tokens(:unconfirmed_token)
    assert_not token.expired?
  end

  test "redeemed? returns true for redeemed token" do
    token = confirmation_tokens(:confirmed_token)
    assert token.redeemed?
  end

  test "redeemed? returns false for unredeemed token" do
    token = confirmation_tokens(:unconfirmed_token)
    assert_not token.redeemed?
  end
end
