class LoadoutController < ApplicationController
    require 'custom_caller'

    @@credentials = {
        'secret_key' => '~~~~~',
        'key_id' => '~~~~~',
        'associate_tag' => 'ultralightpac-20'
    }


    # query all items from database, make api calls to retrieve matching information,
    # package data and send to client to be displayed and manipulated by script file
    def index
        # initialize 'gon' hash to hold items
        gon.items = Hash.new

        # instantiate custom caller object and configure credentials
        request = CustomCaller.new
        request.config(@@credentials)

        # Snag all items from the database
        items = Item.all

        # make api call for each item and snag all relevent info
        items.each do |item|
            # params for request
            request_params = {
                'asin' => item.asin,
                'response_groups' => 'OfferSummary, Images'
             }

            #  instantiate response from api object with request
            response_from_aws = request.item_lookup(request_params)

            # response to client
            # create catagory if it doesn't exist
            if !gon.items[item['catagory']]
                gon.items[item['catagory']] = Array.new
            end

            # push data
            gon.items[item['catagory']].push({
                'id' => item['id'],
                'catagory' => item['catagory'],
                'nickname' => item['nickname'],
                'weight' => item['weight'],
                'description' => item['description'],
                'asin' => item['asin'],
                'link' => item['link'],
                'images' => response_from_aws['images'],
                'price' => response_from_aws['price']
            })
        end
    end

    def index1
        @items = {
            'packs' => [
                {
                    'id' => 1,
                    'catagory' => 'packs',
                    'nickname' => 'MLD Ultralight 40L Backpack',
                    'weight' => 65.3,
                    'description' => 'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using Content here.',
                    'asin' => 'B06XCM9LJ4',
                    'link' => 'http://amzn.to/2gCfiKx',
                    'images' => [
                        {
                            'url' => 'https://images-na.ssl-images-amazon.com/images/I/71iVHuI-TeL._SL1000_.jpg',
                            'height' => 50,
                            'width' => 75,
                            'aspect_ratio' => 0.75
                        },
                        {
                            'url' => 'https://images-na.ssl-images-amazon.com/images/I/61yI7vWa83L._SL1000_.jpg',
                            'height' => 50,
                            'width' => 75,
                            'aspect_ratio' => 0.75
                        },
                        {
                            'url' => 'https://images-na.ssl-images-amazon.com/images/I/71iVHuI-TeL._SL1000_.jpg',
                            'height' => 50,
                            'width' => 75,
                            'aspect_ratio' => 0.75
                        },
                        {
                            'url' => 'https://images-na.ssl-images-amazon.com/images/I/61jLx3KMDfL._SL1000_.jpg',
                            'height' => 50,
                            'width' => 75,
                            'aspect_ratio' => 0.75
                        },
                        {
                            'url' => 'https://images-na.ssl-images-amazon.com/images/I/71iVHuI-TeL._SL1000_.jpg',
                            'height' => 50,
                            'width' => 75,
                            'aspect_ratio' => 0.75
                        }
                    ],
                    'price' => 19.99
                }
            ]
        }
    end





    # create a new shopping cart with the passed items and quantities
    def create
        # instantiate caller object and configure
        custom_caller = CustomCaller.new
        custom_caller.config(@@credentials)

        # params passed from script file
        request_params = {
            'asin' => params['item']['asin'],
            'qty' => params['item']['qty']
        }

        # make call to api
        response_from_aws = custom_caller.create_cart(request_params)

        # append info to response object
        response_to_client = {
            'cart_id' => response_from_aws['cart_id'],
            'hmac' => response_from_aws['hmac'],
            'urlencodedhmac' => response_from_aws['urlencodedhmac'],
            'purchase_url' => response_from_aws['purchase_url'],
            'cart_item_id' => response_from_aws['cart_item_id'],
            'valid' => true
        }

        render json: response_to_client
    end





    # take shopping cart info from client and add item, return same info (check if returned hmac and cart id is necessary, it may not change)
    def add
        # instantiate caller object and configure
        custom_caller = CustomCaller.new
        custom_caller.config(@@credentials)

        # set api call params (cart id, hmac, item asin and qty required)
        request_params = Hash.new

        # set cart params
        request_params['cart'] = {
            'hmac' => params['cart']['hmac'],
            'id' => params['cart']['id'],
            'urlencodedhmac' => params['cart']['urlencodedhmac']
        }

        # set item params
        request_params['item'] = {
            'asin' => params['item']['asin'],
            'qty' => params['item']['qty']
        }

        # make call to api
        response_from_aws = custom_caller.add_cart(request_params)

        # determine if call was successful and send appropriate response to client
        if (response_from_aws['is_valid'])
            response_to_client = {
                'valid' => true,
                'server_message' => 'success',
                'cart_item_id' => response_from_aws['cart_item_id'],
                'purchase_url' => response_from_aws['purchase_url']
            }
        else
            response_to_client = {
                'valid' => false,
                'server_message' => 'failure on api call'
            }
        end

        render json: response_to_client
    end





    # remove item from cart, clear
    def destroy
        # instantiate caller object and configure
        custom_caller = CustomCaller.new
        custom_caller.config(@@credentials)

        # set api call params (cart id, hmac, item asin and qty required)
        request_params = Hash.new

        # set cart params
        request_params['cart'] = {
            'hmac' => params['cart']['hmac'],
            'id' => params['cart']['id'],
            'urlencodedhmac' => params['cart']['urlencodedhmac']
        }

        # set item params
        request_params['item'] = {
            'cart_item_id' => params['item']['cart_item_id'],
            'qty' => params['item']['qty']
        }

        # make api call
        response_from_aws = custom_caller.modify_cart(request_params)

        render json: response_from_aws
    end
end
