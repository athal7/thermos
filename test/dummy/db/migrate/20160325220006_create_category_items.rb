class CreateCategoryItems < ActiveRecord::Migration
  def change
    create_table :category_items do |t|
      t.string :name
      t.integer :category_id
      t.integer :product_id

      t.timestamps null: false
    end
  end
end
