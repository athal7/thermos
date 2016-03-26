module Thermos::Notifier
  extend ActiveSupport::Concern

  included do
    after_save :notify_thermos
  end

  private

  def notify_thermos
    Thermos.model_changed(self)
  end

end
