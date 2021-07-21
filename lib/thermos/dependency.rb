# frozen_string_literal: true

module Thermos
  class Dependency
    attr_reader :model, :path, :klass, :table

    def initialize(model:, ref:, path: nil)
      @model = model
      @path = path
      @table = ref.table_name
      @klass = ref.class_name.constantize
    end
  end
end
