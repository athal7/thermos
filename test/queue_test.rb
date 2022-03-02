require 'test_helper'

class QueueTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  self.use_transactional_tests = true
  teardown :clear_cache

  test 'uses the default background queue by default' do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    assert_performed_with(job: Thermos::RebuildCacheJob, queue: 'default') do
      category.update!(name: 'foo')
    end
    mock.verify
  end

  test 'can specify a preferred queue name for the cache filling' do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category, queue: 'low_priority') do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_performed_with(
      job: Thermos::RebuildCacheJob,
      queue: 'low_priority',
    ) { category.update!(name: 'foo') }
    mock.verify
  end
end
