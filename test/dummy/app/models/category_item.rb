class CategoryItem < ActiveRecord::Base
  belongs_to :category, optional: true
  belongs_to :product, optional: true
end
