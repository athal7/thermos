require "thermos/notifier"
require "thermos/beverage"

module Thermos

  def self.keep_warm(cache_key:, primary_model:, primary_key:, dependencies: [], &block)
    fill(cache_key: cache_key, primary_model: primary_model, dependencies: dependencies, &block)
    drink(cache_key: cache_key, primary_key: primary_key)
  end

  def self.fill(cache_key:, primary_model:, dependencies: [], &block)
    @thermos ||= {}
    @thermos[cache_key] = Beverage.new(cache_key: cache_key, primary_model: primary_model, dependencies: dependencies, action: block)
  end

  def self.drink(cache_key:, primary_key:)
    Rails.cache.fetch([cache_key, primary_key]) do
      @thermos[cache_key].action.call(primary_key)
    end
  end

  def self.model_changed(model)
    refill_primary_caches(model)
    refill_dependency_caches(model)
  end

  def self.empty
    @thermos = {}
  end

  private

  def self.refill_primary_caches(model)
    @thermos.values.select do |beverage|
      beverage.primary_model == model.class
    end.each do |beverage|
      refill(beverage, model.id)
    end
  end

  def self.refill_dependency_caches(model)
    @thermos.values.select do |beverage|
      beverage.dependency_classes.include?(model.class)
    end.each do |beverage|
      beverage.dependencies_for_class(model.class).each do |association|
        beverage_models = beverage.primary_model.joins(association).where("#{association.to_s.pluralize}.id = #{model.id}")
        beverage_models.each do |beverage_model|
          refill(beverage, beverage_model.id)
        end
      end
    end
  end

  def self.refill(beverage, primary_key)
    @thermos[beverage.cache_key] = beverage
    Rails.cache.write([beverage.cache_key, primary_key], beverage.action.call(primary_key))
  end
end
