require "test_helper"

class WaitlistControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  # POST /waitlist - create action
  test "should create new waitlist entry and send confirmation email" do
    assert_difference [ "WaitlistEntry.count", "ConfirmationToken.count" ], 1 do
      assert_enqueued_emails 1 do
        post waitlist_path, params: { email: "newuser@example.com" },
          headers: { "HTTP_USER_AGENT" => "Test Browser" }
      end
    end

    assert_redirected_to root_path
    assert_match /bestätigen Sie Ihre E-Mail-Adresse/, flash[:notice]

    entry = WaitlistEntry.last
    assert_equal "newuser@example.com", entry.email
    assert_not_nil entry.confirmation_token
    assert_not_nil entry.confirmation_token.code
    assert_not_nil entry.signup_ip
    assert_not_nil entry.consent_text
    assert_nil entry.confirmed_at
  end

  test "should normalize email to lowercase" do
    post waitlist_path, params: { email: "UPPERCASE@EXAMPLE.COM" }
    entry = WaitlistEntry.last
    assert_equal "uppercase@example.com", entry.email
  end

  test "should reject blank email" do
    assert_no_difference "WaitlistEntry.count" do
      post waitlist_path, params: { email: "" }
    end

    assert_redirected_to root_path
    assert_match /E-Mail-Adresse/, flash[:alert]
  end

  test "should show message if email already confirmed" do
    confirmed = waitlist_entries(:confirmed)

    assert_no_difference "WaitlistEntry.count" do
      assert_no_enqueued_emails do
        post waitlist_path, params: { email: confirmed.email }
      end
    end

    assert_redirected_to root_path
    assert_match /bereits.*registriert/, flash[:notice]
  end

  test "should regenerate token for unconfirmed email and resend" do
    unconfirmed = waitlist_entries(:unconfirmed)
    old_code = unconfirmed.confirmation_token.code

    assert_no_difference "WaitlistEntry.count" do
      assert_enqueued_emails 1 do
        post waitlist_path, params: { email: unconfirmed.email }
      end
    end

    assert_redirected_to root_path
    assert_match /neue Bestätigungs-E-Mail/, flash[:notice]

    unconfirmed.reload
    assert_not_equal old_code, unconfirmed.confirmation_token.code
  end

  # GET /waitlist/confirm/:token - confirm action
  test "should confirm valid token" do
    unconfirmed = waitlist_entries(:unconfirmed)
    assert_not unconfirmed.confirmed?

    get confirm_waitlist_path(token: unconfirmed.confirmation_token.code),
      headers: { "HTTP_USER_AGENT" => "Confirmation Browser" }

    assert_response :success
    assert_template :confirmed

    unconfirmed.reload
    assert unconfirmed.confirmed?
    assert_not_nil unconfirmed.confirmed_ip
    assert_equal "Confirmation Browser", unconfirmed.confirmed_user_agent

    # Token should be redeemed
    assert unconfirmed.confirmation_token.redeemed?
  end

  test "should show token_invalid for unknown token" do
    get confirm_waitlist_path(token: "XXXX-YYYY-ZZZZ")

    assert_response :success
    assert_template :token_invalid
  end

  test "should show already_confirmed for confirmed entry" do
    confirmed = waitlist_entries(:confirmed)

    get confirm_waitlist_path(token: confirmed.confirmation_token.code)

    assert_response :success
    assert_template :already_confirmed
  end

  test "should show token_expired for expired token" do
    expired = waitlist_entries(:expired_token)

    get confirm_waitlist_path(token: expired.confirmation_token.code)

    assert_response :success
    assert_template :token_expired
  end

  # DSGVO/UWG compliance - data storage verification
  test "should store all required data for legal compliance on signup" do
    post waitlist_path,
      params: { email: "legal@example.com" },
      headers: { "HTTP_USER_AGENT" => "Legal Test Browser" }

    entry = WaitlistEntry.find_by(email: "legal@example.com")

    # Required for DSGVO/UWG proof
    assert_not_nil entry.email
    assert_not_nil entry.signup_ip
    assert_equal "Legal Test Browser", entry.signup_user_agent
    assert_not_nil entry.consent_text
    assert_not_nil entry.created_at  # Timestamp of signup
    assert_not_nil entry.confirmation_token.expires_at
  end

  test "should store all required data for legal compliance on confirmation" do
    unconfirmed = waitlist_entries(:unconfirmed)

    get confirm_waitlist_path(token: unconfirmed.confirmation_token.code),
      headers: { "HTTP_USER_AGENT" => "Confirm Test Browser" }

    unconfirmed.reload

    # Required for DSGVO/UWG proof
    assert_not_nil unconfirmed.confirmed_at  # Timestamp of confirmation
    assert_not_nil unconfirmed.confirmed_ip
    assert_equal "Confirm Test Browser", unconfirmed.confirmed_user_agent
  end
end
