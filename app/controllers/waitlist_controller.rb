class WaitlistController < ApplicationController
  allow_unauthenticated_access

  def create
    email = params[:email]&.downcase&.strip

    if email.blank?
      return redirect_to root_path, alert: "Bitte geben Sie eine E-Mail-Adresse ein."
    end

    existing = WaitlistEntry.find_by(email: email)

    if existing&.confirmed?
      return redirect_to root_path, notice: "Diese E-Mail-Adresse ist bereits für unsere Warteliste registriert. Wir informieren Sie, sobald GoAuftrag verfügbar ist."
    end

    if existing
      # Existiert aber nicht bestätigt - neuen Token generieren
      existing.regenerate_token!
      existing.update!(
        signup_ip: request.remote_ip,
        signup_user_agent: request.user_agent
      )
      WaitlistMailer.confirmation_request(existing).deliver_later
      return redirect_to root_path, notice: "Wir haben Ihnen eine neue Bestätigungs-E-Mail an #{email} gesendet. Bitte prüfen Sie auch Ihren Spam-Ordner."
    end

    # Neuer Eintrag
    entry = WaitlistEntry.new(
      email: email,
      signup_ip: request.remote_ip,
      signup_user_agent: request.user_agent
    )

    if entry.save
      WaitlistMailer.confirmation_request(entry).deliver_later
      redirect_to root_path, notice: "Fast geschafft! Bitte bestätigen Sie Ihre E-Mail-Adresse über den Link, den wir Ihnen gesendet haben."
    else
      redirect_to root_path, alert: entry.errors.full_messages.first || "Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut."
    end
  end

  def confirm
    token = ConfirmationToken.find_by(code: params[:token])

    if token.nil?
      return render :token_invalid
    end

    entry = token.waitlist_entry

    if entry.confirmed?
      return render :already_confirmed
    end

    if token.expired?
      return render :token_expired
    end

    success = token.redeem_if do |waitlist_entry|
      waitlist_entry.confirm!(
        ip: request.remote_ip,
        user_agent: request.user_agent
      )
      true
    end

    if success
      render :confirmed
    else
      render :token_invalid
    end
  end
end
