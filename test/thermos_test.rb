require 'test_helper'

class ThermosTest < ActiveSupport::TestCase
  self.use_transactional_tests = true
  teardown :clear_cache

  test 'keeps the cache warm using fill / drink' do
    mock = Minitest::Mock.new

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 1, [1])
    assert_equal 1, Thermos.drink(key: 'key', id: 1)
    mock.verify

    mock.expect(:call, 2, [1])
    assert_equal 1, Thermos.drink(key: 'key', id: 1)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test 'keeps the cache warm using keep_warm' do
    mock = Minitest::Mock.new

    mock.expect(:call, 1, [1])
    response =
      Thermos.keep_warm(key: 'key', model: Category, id: 1) do |id|
        mock.call(id)
      end
    assert_equal 1, response
    mock.verify

    mock.expect(:call, 2, [1])
    response =
      Thermos.keep_warm(key: 'key', model: Category, id: 1) do |id|
        mock.call(id)
      end
    assert_equal 1, response
    assert_raises(MockExpectationError) { mock.verify }
  end

  # primary model changes
  test 'rebuilds the cache on primary model change' do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: 'key', id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    category.update!(name: 'foo')
    mock.verify

    mock.expect(:call, 3, [category.id])
    assert_equal 2, Thermos.drink(key: 'key', id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test 'does not rebuild the cache on rolled back primary model change' do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: 'key', id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    ActiveRecord::Base.transaction do
      category.update!(name: 'foo')
      raise ActiveRecord::Rollback
    end
    assert_raises(MockExpectationError) { mock.verify }

    mock.expect(:call, 3, [category.id])
    assert_equal 1, Thermos.drink(key: 'key', id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test 'does not rebuild the cache for an unrelated primary model change' do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    other_category = Category.create!(name: 'bar')

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 2, [other_category.id])
    assert_equal 2, Thermos.drink(key: 'key', id: other_category.id)
    mock.verify

    mock.expect(:call, 1, [category.id])
    category.update!(name: 'foo')
    mock.verify

    mock.expect(:call, 3, [other_category.id])
    assert_equal 2, Thermos.drink(key: 'key', id: other_category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test 'does not rebuild the cache on primary model destroy' do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: 'key', id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    category.destroy!
    assert_raises(MockExpectationError) { mock.verify }
  end

  test 'pre-builds cache for new primary model records' do
    mock = Minitest::Mock.new

    Thermos.fill(key: 'key', model: Category, lookup_key: 'name') do |name|
      mock.call(name)
    end

    mock.expect(:call, 1, ['foo'])
    Category.create!(name: 'foo')
    mock.verify

    mock.expect(:call, 2, ['foo'])
    assert_equal 1, Thermos.drink(key: 'key', id: 'foo')
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "accepts and can rebuild off of an id other than the 'id'" do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: 'key', model: Category, lookup_key: :name) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.name])
    assert_equal 1, Thermos.drink(key: 'key', id: category.name)
    mock.verify

    mock.expect(:call, 2, ['foo'])
    category.update!(name: 'foo')
    mock.verify

    mock.expect(:call, 3, [category.name])
    assert_equal 2, Thermos.drink(key: 'key', id: category.name)
    assert_raises(MockExpectationError) { mock.verify }
  end
end
