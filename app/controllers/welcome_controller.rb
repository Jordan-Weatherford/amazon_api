class WelcomeController < ApplicationController
    def index
    end

    def about
    end

    def blog
        # instantiate object for template
        gon.blogs = Array.new

        # query for all blogs
        blogs = Blog.all

        # loop through blogs, query for and append appropriate info
        blogs.each do |blog|
            # grab main image
            main_image = Image.where({ blog_id: blog.id, index: 1 }).first


            gon.blogs.push({
                'id' => blog.id,
                'title' => blog.title,
                'date' => blog.date,
                'coordinates' => {
                    'x' => blog.coord_x,
                    'y' => blog.coord_y
                },
                'image' => main_image.url,
                'subtitle' => main_image.subtitle
            })
        end
    end
end
