# frozen_string_literal: true

module Thermos
  class Dependency
    attr_reader :model, :association, :klass, :table

    def initialize(model:, association:)
      @model = model
      @association = association
      reflection = @model.reflections[@association.to_s]
      @table = reflection.table_name
      @klass = reflection.class_name.constantize
    end
  end
end
