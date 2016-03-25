class Category < ActiveRecord::Base
  has_many :category_items
  has_many :products, through: :category_items

  def as_json(*args)
    {
      name: name,
      category_items: category_items.map do |item|
        {
          name: item.name,
          product_name: item.product.name
        }
      end
    }
  end
end
