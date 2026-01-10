module Authorization
  extend ActiveSupport::Concern

  private
    def ensure_admin
      head :forbidden unless Current.user&.admin?
    end
end
