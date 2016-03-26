require 'test_helper'

class ThermosTest < ActiveSupport::TestCase
  def setup
    @category = Category.create!(name: "baseball")
    @product = Product.create!(name: "glove")
    @category_item = CategoryItem.create!(name: "baseball glove", category: @category, product: @product)
  end

  test "keeps the cache warm using fill / drink" do
    Thermos.fill(cache_key: "categories_show", primary_model: Category, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end

    expected_response = {
      name: "baseball",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    response = Thermos.drink(cache_key: "categories_show", primary_key: @category.id)
    assert_equal expected_response.to_json, response
  end

  test "keeps the cache warm using keep_warm" do
    Thermos.keep_warm(cache_key: "categories_show", primary_model: Category, primary_key: @category.id, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end

    expected_response = {
      name: "baseball",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    response = Thermos.keep_warm(cache_key: "categories_show", primary_model: Category, primary_key: @category.id, dependencies: [:category_items, :products]) do |primary_key|
      raise "boom"
    end
    assert_equal expected_response.to_json, response
  end

end
