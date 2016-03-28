module Thermos
  module Notifier
    extend ActiveSupport::Concern

    included do
      after_save :notify_thermos
    end

    private

    def notify_thermos
      RefillJob.perform_later self
    end
  end
end
