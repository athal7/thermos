module Thermos
  def self.keep_warm(cache_key:, primary_model:, dependencies: [], &block)
    @registry ||= {}
    @registry[cache_key] = Beverage.new(cache_key: cache_key, primary_model: primary_model, dependencies: dependencies, action: block)
  end

  def self.fetch(cache_key:, primary_key:)
    Rails.cache.fetch([cache_key, primary_key]) do
      @registry[cache_key].action.call(primary_key)
    end
  end
end

class Thermos::Beverage
  attr_reader :cache_key, :primary_model, :dependencies, :action

  def initialize(cache_key:, primary_model:, dependencies:, action:)
    @cache_key = cache_key
    @primary_model = primary_model
    @dependencies = dependencies
    @action = action
  end

end

# pseudocode ideas:
#
# class Thermos::Cache
#   def self.models
#     all.reduce(Set.new) do |set, cache|
#       cache.models.each { |m| set.push(m) }
#     end
#   end
#
#   def self.reload_caches_for_dependency(model)
#     reload_primary_caches(model)
#     reload_dependency_caches(model)
#   end
#
#   def self.reload_primary_caches(model)
#     all.filter do |cache|
#       cache.primary == model.class
#     end.each do |cache|
#       rebuild_primary_cache(id: model.id)
#     end
#   end
#
#   def self.reload_dependency_caches(model)
#     all.filter do |cache|
#       cache.dependencies.include? model.class
#     end.each do |cache|
#       rebuild_dependency_cache(model_class: model.class, id: model.id)
#     end
#   end
#
#   def rebuild_primary_cache(id:)
#     Rails.cache.save(cache_key(id: id)) do
#       action.call(id)
#     end
#   end
#
#   def rebuild_dependency_cache(model_class:, id:)
#     # figure out association to primary
#     reflection = primary.reflections.filter do |reflection|
#       reflection.class == model_class
#     end.each do |reflection|
#       instances = primary.joins(reflection).where(reflection.id = id)
#       # rebuild_primary_cache for primary id
#       instances.each { |i| rebuild_primary_cache(id: i) }
#     end
#   end
#
#   def cache_key(id:)
#     [key, primary, id]
#   end
#
#   def self.read_cache(key:, id:)
#     cache = all.find { |cache| cache.key == key }
#     Rails.cache.read(cache.cache_key(id: id))
#   end
#
#   def models
#     [dependencies + primary].compact
#   end
# end
#
# Thermos::Config
# caches = []
# caches.models.each { |m| add_observer(QueuedObserver) }
#
# def on_update
#   Thermos::Cache.reload_caches_for_dependency(model)
# end
#
