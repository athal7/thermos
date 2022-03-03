class Category < ActiveRecord::Base
  has_many :category_items
  has_many :products, through: :category_items
  belongs_to :store

  def ball?
    name.match('ball')
  end

  def as_json(*args)
    {
      name: name,
      store_name: store.name,
      category_items:
        category_items.map do |item|
          { name: item.name, product_name: item.product.name }
        end,
    }
  end
end
