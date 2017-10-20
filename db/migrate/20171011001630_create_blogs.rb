class CreateBlogs < ActiveRecord::Migration[5.0]
  def change
    create_table :blogs do |t|
      t.string :title
      t.integer :index
      t.string :date
      t.float :coord_x
      t.float :coord_y

      t.timestamps
    end
  end
end
