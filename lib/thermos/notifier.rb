# frozen_string_literal: true

module Thermos
  module Notifier
    extend ActiveSupport::Concern

    included do
      after_commit :notify_thermos
    end

    private

    def notify_thermos
      RefillJob.perform_later self
    end
  end
end
