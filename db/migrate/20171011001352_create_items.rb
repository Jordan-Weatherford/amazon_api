class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :nickname
      t.float :weight
      t.float :price
      t.text :description
      t.string :asin
      t.string :url

      t.timestamps
    end
  end
end
