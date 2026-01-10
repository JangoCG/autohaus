class ConfirmationToken < ApplicationRecord
  CODE_LENGTH = 12
  EXPIRATION_TIME = 24.hours

  belongs_to :waitlist_entry

  validates :code, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(redeemed_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :redeemed, -> { where.not(redeemed_at: nil) }

  before_validation :generate_code, on: :create, if: -> { code.blank? }
  before_validation :set_expiration, on: :create, if: -> { expires_at.blank? }

  def redeem_if(&block)
    with_lock do
      if active? && block.call(waitlist_entry)
        update!(redeemed_at: Time.current)
        true
      else
        false
      end
    end
  end

  def active?
    redeemed_at.nil? && expires_at > Time.current
  end

  def expired?
    expires_at <= Time.current
  end

  def redeemed?
    redeemed_at.present?
  end

  def reset
    generate_code
    self.expires_at = EXPIRATION_TIME.from_now
    self.redeemed_at = nil
    save!
  end

  private
    def generate_code
      self.code = loop do
        candidate = SecureRandom.base58(CODE_LENGTH).scan(/.{4}/).join("-")
        break candidate unless self.class.exists?(code: candidate)
      end
    end

    def set_expiration
      self.expires_at = EXPIRATION_TIME.from_now
    end
end
