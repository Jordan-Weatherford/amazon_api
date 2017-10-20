class AddMainImageColumnToBlogs < ActiveRecord::Migration[5.0]
  def change
    add_column :blogs, :main_image, :string
  end
end
