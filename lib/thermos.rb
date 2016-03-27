require "thermos/beverage"
require "thermos/dependency"
require "thermos/notifier"
require "thermos/refill_job"

module Thermos

  def self.keep_warm(key:, model:, id:, deps: [], lookup_key: nil, &block)
    fill(key: key, model: model, deps: deps, lookup_key: lookup_key, &block)
    drink(key: key, id: id)
  end

  def self.fill(key:, model:, deps: [], lookup_key: nil, &block)
    @thermos ||= {}
    @thermos[key] = Beverage.new(key: key, model: model, deps: deps, action: block, lookup_key: lookup_key)
  end

  def self.drink(key:, id:)
    Rails.cache.fetch([key, id]) do
      @thermos[key].action.call(id)
    end
  end

  def self.empty
    @thermos = {}
  end

  def self.refill_primary_caches(model)
    @thermos.values.select do |beverage|
      beverage.model == model.class
    end.each do |beverage|
      refill(beverage, model.send(beverage.lookup_key))
    end
  end

  def self.refill_dependency_caches(model)
    @thermos.values.each do |beverage|
      deps = beverage.deps.select { |dependency| dependency.klass == model.class }
      deps.each do |dependency|
        beverage_models = beverage.model.joins(dependency.association).where(dependency.table => { id: model.id })
        beverage_models.each do |beverage_model|
          refill(beverage, beverage_model.send(beverage.lookup_key))
        end
      end
    end
  end

  def self.refill(beverage, id)
    @thermos[beverage.key] = beverage
    Rails.cache.write([beverage.key, id], beverage.action.call(id))
  end
end
