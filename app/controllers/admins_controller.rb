class AdminsController < ApplicationController
    def index
        if !session['user']
            redirect_to '/login'
        end

        @items = Item.all
    end

    def login
        
    end
end
