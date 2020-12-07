# frozen_string_literal: true

module Thermos
  class Beverage
    attr_reader :key, :model, :deps, :action, :lookup_key, :filter

    def initialize(key:, model:, deps:, action:, lookup_key: nil, filter: nil)
      @key = key
      @model = model
      @lookup_key = lookup_key || :id
      @filter = filter || nil
      @deps = deps.map do |dep|
        Dependency.new(model: model, association: dep)
      end
      @action = action

      set_observers
    end

    def lookup_keys_for_dep_model(dep_model)
      @deps.flat_map do |dep|
        return [] unless dep.klass == dep_model.class
        @model.joins(dep.association)
              .where(dep.table => { id: dep_model.id })
              .pluck(@lookup_key)
      end.uniq
    end

    def should_fill?(model)
      @filter.class == Proc ? !!@filter.call(model) : true
    end

    private

    def set_observers
      observe(@model)
      @deps.each { |dep| observe(dep.klass) }
    end

    def observe(model)
      model.include(Notifier) unless model.included_modules.include?(Notifier)
    end
  end
end
