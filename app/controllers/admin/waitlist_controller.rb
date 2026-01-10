class Admin::WaitlistController < AdminController
  def index
    @total = WaitlistEntry.count
    @confirmed = WaitlistEntry.confirmed.count
    @unconfirmed = WaitlistEntry.unconfirmed.count

    @last_24_hours = WaitlistEntry.where(created_at: 24.hours.ago..).count
    @last_7_days = WaitlistEntry.where(created_at: 7.days.ago..).count

    @recent_entries = WaitlistEntry.order(created_at: :desc).limit(20)
    @recent_confirmed = WaitlistEntry.confirmed.order(confirmed_at: :desc).limit(10)
  end
end
