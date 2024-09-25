require "test_helper"

class DependenciesTest < ActiveJob::TestCase
  self.use_transactional_tests = true
  teardown :clear_cache

  test "rebuilds the cache on has_many model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    category_item = category_items(:baseball_glove)

    Thermos.fill(key: "key", model: Category, deps: [:category_items]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { category_item.update!(name: "foo") }
    mock.verify

    mock.expect(:call, 3, [category.id])
    assert_equal 2, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "does not rebuild the cache for an unrelated has_many model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    category_item = CategoryItem.create(category: nil)

    Thermos.fill(key: "key", model: Category, deps: [:category_items]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { category_item.update!(name: "foo") }
    assert_raises(MockExpectationError) { mock.verify }

    mock.expect(:call, 3, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for new has_many records" do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: "key", model: Category, deps: [:category_items]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { CategoryItem.create!(category: category) }
    mock.verify

    mock.expect(:call, 2, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for has_many record changes when filter condition is met" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    filter = ->(model) { model.ball? }

    Thermos.fill(
      key: "key",
      model: Category,
      deps: [:category_items],
      filter: filter,
    ) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { CategoryItem.create!(category: category) }
    mock.verify

    perform_enqueued_jobs { category.update!(name: "hockey") }

    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { CategoryItem.create!(category: category) }
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "rebuilds the cache on belongs_to model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    store = stores(:sports)

    Thermos.fill(key: "key", model: Category, deps: [:store]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { store.update!(name: "foo") }
    mock.verify

    mock.expect(:call, 3, [category.id])
    assert_equal 2, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "does not rebuild the cache for an unrelated belongs_to model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    store = Store.create!

    Thermos.fill(key: "key", model: Category, deps: [:store]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    store.update!(name: "foo")
    assert_raises(MockExpectationError) { mock.verify }

    mock.expect(:call, 3, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for new belongs_to records" do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: "key", model: Category, deps: [:store]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { Store.create!(name: "foo", categories: [category]) }
    mock.verify

    mock.expect(:call, 2, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for belongs_to record changes when filter condition is met" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    filter = ->(model) { model.ball? }

    Thermos.fill(
      key: "key",
      model: Category,
      deps: [:store],
      filter: filter,
    ) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { Store.create!(name: "foo", categories: [category]) }
    mock.verify

    category.update!(name: "hockey")

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { Store.create!(name: "bar", categories: [category]) }
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "rebuilds the cache on has_many through model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    product = products(:glove)

    Thermos.fill(key: "key", model: Category, deps: [:products]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { product.update!(name: "foo") }
    mock.verify

    mock.expect(:call, 3, [category.id])
    assert_equal 2, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "does not rebuild the cache for an unrelated has_many through model change" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    product = Product.create!

    Thermos.fill(key: "key", model: Category, deps: [:products]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    mock.verify

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { product.update!(name: "foo") }
    assert_raises(MockExpectationError) { mock.verify }

    mock.expect(:call, 3, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for new has_many through records" do
    mock = Minitest::Mock.new
    category = categories(:baseball)

    Thermos.fill(key: "key", model: Category, deps: [:products]) do |id|
      mock.call(id)
    end

    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { Product.create!(categories: [category]) }
    mock.verify

    mock.expect(:call, 2, [category.id])
    assert_equal 1, Thermos.drink(key: "key", id: category.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "re-builds the cache for has_many through record changes when filter condition is met" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    filter = ->(model) { model.ball? }

    Thermos.fill(
      key: "key",
      model: Category,
      deps: [:products],
      filter: filter,
    ) { |id| mock.call(id) }

    mock.expect(:call, 1, [category.id])
    perform_enqueued_jobs { Product.create!(categories: [category]) }
    mock.verify

    category.update!(name: "hockey")

    mock.expect(:call, 2, [category.id])
    perform_enqueued_jobs { Product.create!(categories: [category]) }
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "handles indirect associations" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    store = category.store

    Thermos.fill(
      key: "key",
      model: Store,
      deps: [categories: [:products]],
    ) { |id| mock.call(id) }

    mock.expect(:call, 1, [store.id])
    perform_enqueued_jobs { category.update!(name: "foo") }
    mock.verify

    mock.expect(:call, 2, [store.id])
    assert_equal 1, Thermos.drink(key: "key", id: store.id)
    assert_raises(MockExpectationError) { mock.verify }
    perform_enqueued_jobs { Product.create!(categories: [category]) }
    mock.verify

    mock.expect(:call, 3, [store.id])
    assert_equal 2, Thermos.drink(key: "key", id: store.id)
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "only rebuilds cache for stated dependencies, even if another cache has an associated model of the primary" do
    category_mock = Minitest::Mock.new
    product_mock = Minitest::Mock.new
    category = categories(:baseball)
    product = products(:glove)

    Thermos.fill(key: "category_key", model: Category) do |id|
      category_mock.call(id)
    end

    Thermos.fill(key: "product_key", model: Product) do |id|
      product_mock.call(id)
    end

    category_mock.expect(:call, 2, [category.id])
    product_mock.expect(:call, 2, [product.id])
    perform_enqueued_jobs { product.update!(name: "foo") }
    assert_raises(MockExpectationError) { category_mock.verify }
    product_mock.verify
  end
end
