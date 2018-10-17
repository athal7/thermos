# frozen_string_literal: true

module Thermos
  class RebuildCacheJob < ActiveJob::Base
    def perform(key, id)
      beverage = BeverageStorage.instance.get_beverage(key)
      Rails.cache.write([key, id], beverage.action.call(id))
    end
  end
end
