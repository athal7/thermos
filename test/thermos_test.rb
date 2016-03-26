require 'test_helper'

class ThermosTest < ActiveSupport::TestCase
  def setup
    @store = Store.create!(name: "sports store")
    @category = Category.create!(name: "baseball", store: @store)
    @product = Product.create!(name: "glove")
    @category_item = CategoryItem.create!(name: "baseball glove", category: @category, product: @product)
  end

  def teardown
    Thermos.empty
    Rails.cache.clear
    @store.destroy!
    @category_item.destroy!
    @category.destroy!
    @product.destroy!
  end

  def cache_key
    "categories_show"
  end

  def primary_model
    @category.class
  end

  def dependencies
    [:store, :category_items, :products]
  end

  def fill
    Thermos.fill(cache_key: cache_key, primary_model: primary_model, dependencies: dependencies) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  def fill_with_error
    Thermos.fill(cache_key: cache_key, primary_model: primary_model, dependencies: dependencies) do |primary_key|
      raise "boom"
    end
  end

  def drink
    Thermos.drink(cache_key: cache_key, primary_key: @category.id)
  end

  def keep_warm
    Thermos.keep_warm(cache_key: cache_key, primary_model: primary_model, primary_key: @category.id, dependencies: dependencies) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  def keep_error_warm
    Thermos.keep_warm(cache_key: cache_key, primary_model: primary_model, primary_key: @category.id, dependencies: dependencies) do |primary_key|
      raise "boom"
    end
  end

  test "keeps the cache warm using fill / drink" do
    fill

    expected_response = {
      name: "baseball",
      store_name: "sports store",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    assert_equal expected_response.to_json, drink

    fill_with_error

    assert_equal expected_response.to_json, drink
  end

  test "keeps the cache warm using keep_warm" do
    keep_warm

    expected_response = {
      name: "baseball",
      store_name: "sports store",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end

  test "rebuilds the cache on primary model change" do
    keep_warm

    @category.update!(name: "softball")

    expected_response = {
      name: "softball",
      store_name: "sports store",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end

  test "rebuilds the cache on has_many model change" do
    keep_warm

    @category_item.update!(name: "catcher's mitt")

    expected_response = {
      name: "baseball",
      store_name: "sports store",
      category_items: [{
        name: "catcher's mitt",
        product_name: "glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end

  test "rebuilds the cache on belongs_to model change" do
    keep_warm

    @store.update!(name: "baseball store")

    expected_response = {
      name: "baseball",
      store_name: "baseball store",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end

  test "rebuilds the cache on has_many through model change" do
    keep_warm

    @product.update!(name: "batting glove")

    expected_response = {
      name: "baseball",
      store_name: "sports store",
      category_items: [{
        name: "baseball glove",
        product_name: "batting glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end
end
