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
        deps = beverage.deps.select { |dependency| dependency.klass == model.class }
        deps.each do |dependency|
          beverage_models = beverage.model.joins(dependency.association).where(dependency.table => { id: model.id })
          beverage_models.find_each do |beverage_model|
            Thermos::RebuildCacheJob.perform_later(beverage.key, beverage_model.send(beverage.lookup_key))
          end
        end
      end
    end
  end
end
