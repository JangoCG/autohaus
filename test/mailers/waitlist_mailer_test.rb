require "test_helper"

class WaitlistMailerTest < ActionMailer::TestCase
  test "confirmation_request sends email with correct data" do
    entry = waitlist_entries(:unconfirmed)
    email = WaitlistMailer.confirmation_request(entry)

    # Verify email metadata
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "noreply@goauftrag.de" ], email.from
    assert_equal [ entry.email ], email.to
    assert_equal "Bitte bestätigen Sie Ihre E-Mail-Adresse", email.subject
  end

  test "confirmation_request contains confirmation link" do
    entry = waitlist_entries(:unconfirmed)
    email = WaitlistMailer.confirmation_request(entry)

    # Check HTML part
    assert_match entry.confirmation_token.code, email.html_part.body.to_s
    assert_match "waitlist/confirm", email.html_part.body.to_s

    # Check text part
    assert_match entry.confirmation_token.code, email.text_part.body.to_s
    assert_match "waitlist/confirm", email.text_part.body.to_s
  end

  test "confirmation_request mentions 24 hour validity" do
    entry = waitlist_entries(:unconfirmed)
    email = WaitlistMailer.confirmation_request(entry)

    assert_match "24 Stunden", email.html_part.body.to_s
    assert_match "24 Stunden", email.text_part.body.to_s
  end

  test "confirmation_request is neutral without advertising (LG Stendal compliance)" do
    entry = waitlist_entries(:unconfirmed)
    email = WaitlistMailer.confirmation_request(entry)

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    # Should NOT contain promotional content
    assert_no_match /kostenlos/i, html_body
    assert_no_match /angebot/i, html_body
    assert_no_match /rabatt/i, html_body
    assert_no_match /kontaktieren sie uns/i, html_body

    assert_no_match /kostenlos/i, text_body
    assert_no_match /angebot/i, text_body
    assert_no_match /rabatt/i, text_body
    assert_no_match /kontaktieren sie uns/i, text_body
  end

  test "confirmation_request includes ignore notice" do
    entry = waitlist_entries(:unconfirmed)
    email = WaitlistMailer.confirmation_request(entry)

    # Per DSGVO best practice: mention what to do if not signed up
    assert_match /nicht angemeldet/i, email.html_part.body.to_s
    assert_match /ignorieren/i, email.html_part.body.to_s
  end
end
