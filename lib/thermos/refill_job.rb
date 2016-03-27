class Thermos::RefillJob < ActiveJob::Base
  def perform(model)
    Thermos.refill_primary_caches(model)
    Thermos.refill_dependency_caches(model)
  end
end
