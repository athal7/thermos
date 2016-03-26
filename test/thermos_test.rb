require 'test_helper'

class ThermosTest < ActiveSupport::TestCase
  def setup
    @category = Category.create!(name: "baseball")
    @product = Product.create!(name: "glove")
    @category_item = CategoryItem.create!(name: "baseball glove", category: @category, product: @product)
  end

  def teardown
    Thermos.empty
    Rails.cache.clear
    @category_item.destroy!
    @category.destroy!
    @product.destroy!
  end

  def fill
    Thermos.fill(cache_key: "categories_show", primary_model: Category, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  def fill_with_error
    Thermos.fill(cache_key: "categories_show", primary_model: Category, dependencies: [:category_items, :products]) do |primary_key|
      raise "boom"
    end
  end

  def drink
    Thermos.drink(cache_key: "categories_show", primary_key: @category.id)
  end

  def keep_warm
    Thermos.keep_warm(cache_key: "categories_show", primary_model: Category, primary_key: @category.id, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  def keep_error_warm
    Thermos.keep_warm(cache_key: "categories_show", primary_model: Category, primary_key: @category.id, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  test "keeps the cache warm using fill / drink" do
    fill

    expected_response = {
      name: "baseball",
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
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    keep_error_warm
    assert_equal expected_response.to_json, keep_warm
  end
end
