class Thermos::Beverage
  attr_reader :cache_key, :primary_model, :dependencies, :action

  def initialize(cache_key:, primary_model:, dependencies:, action:)
    @cache_key = cache_key
    @primary_model = primary_model
    @dependencies = dependencies
    @action = action

    set_observers
  end

  def dependency_classes
    @dependencies.map do |dependency|
      @primary_model.reflections[dependency.to_s].class_name.constantize
    end
  end

  def dependencies_for_class(klazz)
    @dependencies.select do |dependency|
      @primary_model.reflections[dependency.to_s].class_name == klazz.name
    end
  end

  private

  def set_observers
    observe(@primary_model)
    dependency_classes.each { |klazz| observe(klazz) }
  end

  def observe(model)
    model.include(Thermos::Notifier) unless model.included_modules.include?(Thermos::Notifier)
  end
end
