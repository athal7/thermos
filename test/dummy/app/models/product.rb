class Product < ActiveRecord::Base
  has_many :category_items
  has_many :categories, through: :category_items
end
