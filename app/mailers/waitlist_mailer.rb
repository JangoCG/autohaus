class WaitlistMailer < ApplicationMailer
  def confirmation_request(entry)
    @entry = entry
    @confirmation_url = confirm_waitlist_url(token: entry.confirmation_token.code)

    mail(
      to: entry.email,
      subject: "Bitte bestätigen Sie Ihre E-Mail-Adresse"
    )
  end
end
