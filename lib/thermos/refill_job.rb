# frozen_string_literal: true

module Thermos
  class RefillJob < ActiveJob::Base
    def perform(model)
      refill_primary_caches(model)
      refill_dependency_caches(model)
    end

    def refill_primary_caches(model)
      BeverageStorage.instance.beverages.each do |beverage|
        if beverage.model == model.class
          Thermos::RebuildCacheJob.perform_later(beverage.key, model.send(beverage.lookup_key))
        end
      end
    end

    def refill_dependency_caches(model)
      BeverageStorage.instance.beverages.each do |beverage|
        beverage.lookup_keys_for_dep_model(model).each do |lookup_key|
          Thermos::RebuildCacheJob.perform_later(beverage.key, lookup_key)
        end
      end
    end
  end
end
