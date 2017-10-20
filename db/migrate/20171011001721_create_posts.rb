class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.references :blog, foreign_key: true
      t.text :comment
      t.integer :index

      t.timestamps
    end
  end
end
