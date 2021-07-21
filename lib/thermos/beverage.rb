# frozen_string_literal: true

module Thermos
  class Beverage
    attr_reader :key, :model, :deps, :action, :lookup_key, :filter

    def initialize(key:, model:, deps:, action:, lookup_key: nil, filter: nil)
      @key = key
      @model = model
      @lookup_key = lookup_key || :id
      @filter = filter || nil
      @deps = generate_deps(model, deps)
      @action = action

      set_observers
    end

    def lookup_keys_for_dep_model(dep_model)
      @deps.flat_map do |dep|
        return [] unless dep.klass == dep_model.class
        @model.joins(dep.path)
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

    def generate_deps(model, deps, root = nil, path = nil)
      deps.reduce([]) do |acc, dep|
        if dep.is_a? Symbol
          acc << Dependency.new(
            model: root || model, 
            ref: model.reflect_on_association(dep), 
            path: path || dep)
        elsif dep.is_a? Array
          dep.each do |d| 
            acc << Dependency.new(
              model: root || model, 
              ref: model.reflect_on_association(d), 
              path: path || d)
          end
        elsif dep.is_a? Hash
          dep.each do |k,v|
            ref = model.reflect_on_association(k)
            acc << Dependency.new(
              model: root || model, 
              ref: ref, 
              path: path || k
            )
            acc.concat(generate_deps(ref.class_name.constantize, v, model, dep))
          end
        end
        acc
      end
    end
  end
end
