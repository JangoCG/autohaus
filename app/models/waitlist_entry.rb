class WaitlistEntry < ApplicationRecord
  CONSENT_TEXT = "Mit der Anmeldung erkläre ich mich einverstanden, über Neuigkeiten zu GoAuftrag per E-Mail informiert zu werden. Ich kann mich jederzeit abmelden.".freeze

  has_one :confirmation_token, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :set_consent_text, on: :create
  after_create :create_confirmation_token!

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  delegate :code, :active?, :expired?, to: :confirmation_token, prefix: :token, allow_nil: true

  def confirmed?
    confirmed_at.present?
  end

  def confirm!(ip:, user_agent:)
    update!(
      confirmed_at: Time.current,
      confirmed_ip: ip,
      confirmed_user_agent: user_agent
    )
  end

  def regenerate_token!
    if confirmation_token
      confirmation_token.reset
    else
      create_confirmation_token!
    end
  end

  private
    def set_consent_text
      self.consent_text = CONSENT_TEXT
    end
end
