class Thermos::Beverage
  attr_reader :cache_key, :primary_model, :dependencies, :action

  def initialize(cache_key:, primary_model:, dependencies:, action:)
    @cache_key = cache_key
    @primary_model = primary_model
    @dependencies = dependencies.map do |dependency|
      Thermos::Dependency.new(primary_model: primary_model, association_name: dependency)
    end
    @action = action

    set_observers
  end

  def dependencies_for_class(klass)
    @dependencies.select do |dependency|
      dependency.klass_name == klass.name
    end
  end

  private

  def set_observers
    observe(@primary_model)
    @dependencies.each { |dependency| observe(dependency.klass_name) }
  end

  def observe(model)
    model.include(Thermos::Notifier) unless model.included_modules.include?(Thermos::Notifier)
  end
end
