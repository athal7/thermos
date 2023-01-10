require "test_helper"

class FilterTest < ActiveSupport::TestCase
  self.use_transactional_tests = true
  teardown :clear_cache

  test "allows filtering for which records should be rebuilt" do
    mock = Minitest::Mock.new
    category = categories(:baseball)
    filter = ->(model) { model.name.match("ball") }
    Thermos.fill(
      key: "key",
      model: Category,
      lookup_key: "name",
      filter: filter,
    ) { |name| mock.call(name) }

    mock.expect(:call, 1, ["basketball"])
    category.update!(name: "basketball")
    mock.verify

    mock.expect(:call, 1, ["hockey"])
    category.update!(name: "hockey")
    assert_raises(MockExpectationError) { mock.verify }
  end

  test "allows filtering based on the beverage when multiple beverages are configured and only one of them has a filter" do
    mock = Minitest::Mock.new
    store = stores(:supermarket)
    category = categories(:baseball)

    # filter method specific to one model
    # store.ball? doesn't exist
    filter = ->(model) { model.ball? }

    Thermos.fill(
      key: "key",
      model: Category,
      lookup_key: "name",
      filter: filter,
    ) { |name| mock.call(name) }

    Thermos.fill(key: "key_2", model: Store, lookup_key: "name") do |name|
      mock.call(name)
    end

    mock.expect(:call, 1, ["groceries"])
    store.update!(name: "groceries")
    assert_equal 1, Thermos.drink(key: "key_2", id: "groceries")
    mock.verify
  end
end
