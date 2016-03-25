require 'test_helper'

class ThermosTest < ActiveSupport::TestCase
  def setup
    category = Category.create!(name: "baseball")
    product = Product.create!(name: "glove")
    category_item = CategoryItem.create!(name: "baseball glove", category: category, product: product)

    Thermos.keep_warm(cache_key: "categories_show", primary_model: Category, dependencies: [:category_items, :products]) do |primary_key|
      Category.find(primary_key).to_json
    end
  end

  test "returns the expected response on the first request" do
    response = Thermos.fetch(cache_key: "categories_show", primary_key: 1)

    expected_response = {
      name: "baseball",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    assert_equal expected_response.to_json, response
  end

  test "returns the expected response on the second request, and pulls it from cache" do
    Thermos.fetch(cache_key: "categories_show", primary_key: 1)

    # TODO assert Category.find isn't called
    response = Thermos.fetch(cache_key: "categories_show", primary_key: 1)

    expected_response = {
      name: "baseball",
      category_items: [{
        name: "baseball glove",
        product_name: "glove"
      }]
    }

    assert_equal expected_response.to_json, response
  end
end
