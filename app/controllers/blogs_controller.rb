class BlogsController < ApplicationController
    def index
        @blogs = Array.new

        blogs = Blog.all

        blogs.each do |blog|
            # grab image with index of '1'
            image_query = Image.where({
                'blog_id': blog.id,
                'index': 1
                }).first

            # package info in hash
            image = {
                'subtitle' => image_query.subtitle,
                'url' => image_query.url
            }

            # push to hash object template
            @blogs.push({
                'index' => blog.index,
                'id' => blog.id,
                'title' => blog.title,
                'image' => image,
                'date' => blog.date,
                'main_image' => blog.main_image,
                'coordinates' => {
                    'x' => blog.coord_x,
                    'y' => blog.coord_y
                    }
                })
        end
    end

    def show
        # query for all blog info, order ascending by 'index' defined during creation
        blog = Blog.find(params['id'])
        images = Image.where(blog_id: params['id']).order(index: :asc)
        posts = Post.where(blog_id: params['id']).order(index: :asc)

        # append info
        @blog = {
            'id' => blog.id,
            'title' => blog.title,
            'date' => blog.date,
            'main_image' => blog.main_image,
            'coordinates' => {
                'x' => blog.coord_x,
                'y' => blog.coord_y
            },
            'images' => Array.new,
            'posts' => Array.new
        }

        # push in images
        images.each do |image|
            @blog['images'].push({
                'url' => image.url,
                'subtitle' => image.subtitle
                })
        end

        # and push in posts
        posts.each do |post|
            @blog['posts'].push(post.comment)
        end
    end
end
