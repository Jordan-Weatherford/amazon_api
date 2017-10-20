class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.references :blog, foreign_key: true
      t.string :url
      t.string :subtitle
      t.integer :index

      t.timestamps
    end
  end
end
