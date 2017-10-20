class CustomCaller
    require 'time'
    require 'uri'
    require 'openssl'
    require 'base64'
    require 'open-uri'
    # require 'rest-client'

    # initialize for use with aws associate api
    def initialize
        @service = 'AWSECommerceService'
        @endpoint = 'webservices.amazon.com'

        # change this to change region
        @uri = '/onca/xml'
    end

    # configure with passed in credentials
    def config(params)
        @access_key_id = params['key_id']
        @associate_tag = params['associate_tag']
        @secret_key = params['secret_key']
    end






# alexa routes
    def echo_chart
        params = {
            "Service" => "AWSECommerceService",
            "Operation" => "ItemLookup",
            "AWSAccessKeyId" => @access_key_id,
            "AssociateTag" => @associate_tag,
            "ItemId" => "B01DFKC2SO, B06XCM9LJ4, B075RWFCHB, B01BH83OOM, B073SQYXTW, B01J24C0TI",
            "IdType" => "ASIN",
            "IncludeReviewsSummary" => "true",
            "ResponseGroup" => "Images,Offers,OfferSummary,PromotionSummary,Reviews"
        }

        signed_url = self.create_url(params)

        response_from_aws = Nokogiri::HTML(open(signed_url))

        thumbs = response_from_aws.xpath("//items/item/smallimage/url")
        prices = response_from_aws.xpath("//items/item/offersummary/lowestnewprice/formattedprice")
        reviews = response_from_aws.xpath("//items/item/customerreviews/iframeurl")

        response_to_controller = {
            'thumbs' => Array.new,
            'prices' => Array.new,
            'reviews' => Array.new,
        }

        for i in 0..thumbs.length
            response_to_controller['thumbs'].push(thumbs[i].text)
            response_to_controller['prices'].push(prices[i].text)
            response_to_controller['reviews'].push(reviews[i].text)
        end

        return response_to_controller
    end










    def item_lookup (params)
        request_params = {
            'Service' => @service,
            'Operation' => 'ItemLookup',
            'AWSAccessKeyId' => @access_key_id,
            'AssociateTag' => @associate_tag,
            'ItemId' => params['asin'],
            'IdType' => 'ASIN',
            'ResponseGroup' => params['response_groups']
        }

        # call helper method to build signed url with all params
        signed_url = self.create_url(request_params)

        # make call to api
        response_from_aws = Nokogiri::HTML(open(signed_url))

        # parse out response
        # grab 6 images create image arrays
        large_image_array = Array.new
        thumbnail_image_array = Array.new

        # grab large and thumbnail image sets from xml response
        large_image_set = response_from_aws.xpath("//imageset/largeimage")
        thumbnail_image_set = response_from_aws.xpath("//imageset/thumbnailimage")

        # loop through retreived large images and set url, height and width to custom image array
        large_image_set.each do |image|
            url = image.css('url').text
            width = image.css('width').text
            height = image.css('height').text

            img_obj = {
                'url' => url,
                'height' => height,
                'width' => width
            }

            large_image_array.push(img_obj)
        end

        # loop through retreived thumbnail images and set url, height and width to custom image array
        thumbnail_image_set.each do |image|
            url = image.css('url').text
            width = image.css('width').text
            height = image.css('height').text
            aspect_ratio = (width.to_f / height.to_f).toFixed(2)

            img_obj = {
                'url' => url,
                'height' => height,
                'width' => width,
                'aspect_ratio' => aspect_ratio
            }

            thumbnail_image_array.push(img_obj)
        end

        # reverse large image array and thumbnail image arrays to correct order
        ordered_large_image_array = Array.new
        ordered_thumbnail_image_array = Array.new

        for i in 0..large_image_array.length
            ordered_large_image_array.push(large_image_array[i])
            ordered_thumbnail_image_array.push(thumbnail_image_array[i])
        end


        # instantiate response object and populate with data
        response_to_controller = {
            'images' => {
                'large_imageset' => ordered_large_image_array,
                'thumbnail_imageset' => ordered_thumbnail_image_array
            },
            'price' => response_from_aws.xpath("//lowestnewprice/formattedprice").text
        }

        return response_to_controller
    end


    def create_cart (params)
        request_params = {
            'Service' => @service,
            'Operation' => 'CartCreate',
            'AWSAccessKeyId' => @access_key_id,
            'AssociateTag' => @associate_tag,
            'Item.1.ASIN' => params['asin'],
            'Item.1.Quantity' => params['qty'],
            'ResponseGroup' => 'Cart'
        }


        # create signed url with all data
        signed_url = self.create_url(request_params)

        # make call to api
        response_from_aws = Nokogiri::HTML(open(signed_url))

        # parse out desired information (cart id, hmac)
        cart_id = response_from_aws.xpath("//cart/cartid").text
        hmac = response_from_aws.xpath("//cart/hmac").text
        urlencodedhmac = response_from_aws.xpath("//cart/urlencodedhmac").text
        purchase_url = response_from_aws.xpath("//cart/purchaseurl").text
        cart_item_id = response_from_aws.xpath("//cart/cartitems/cartitem/cartitemid").first.text
        is_valid = response_from_aws.xpath("//isvalid").text

        # set response
        if is_valid
            response_to_controller = {
                'cart_id' => cart_id,
                'hmac' => hmac,
                'urlencodedhmac' => urlencodedhmac,
                'purchase_url' => purchase_url,
                'cart_item_id' => cart_item_id
            }
        end
        response_to_controller['is_valid'] = is_valid

        return response_to_controller
    end


    def add_cart (params)
        request_params = {
            'Service' => @service,
            'Operation' => 'CartAdd',
            'CartId' => params['cart']['id'],
            'HMAC' => params['cart']['hmac'],
            'URLEncodedHMAC' => params['cart']['urlencodedhmac'],
            'AWSAccessKeyId' => @access_key_id,
            'AssociateTag' => @associate_tag,
            'Item.1.ASIN' => params['item']['asin'],
            'Item.1.Quantity' => params['item']['qty'],
            'ResponseGroup' => 'Cart'
        }


        # create signed url with all data
        signed_url = self.create_url(request_params)

        # make call to api
        response_from_aws = Nokogiri::HTML(open(signed_url))

        # parse out desired information (cart id, hmac)
        cart_id = response_from_aws.xpath("//cart/cartid").text
        hmac = response_from_aws.xpath("//cart/hmac").text
        urlencodedhmac = response_from_aws.xpath("//cart/urlencodedhmac").text
        purchase_url = response_from_aws.xpath("//cart/purchaseurl").text
        is_valid = response_from_aws.xpath("//isvalid").text

        # double checking must be done that this is in fact, always the correct item id
        cart_item_id = response_from_aws.xpath("//cart/cartitems/cartitem/cartitemid").first.text

        # set appropriate response
        if is_valid
            response_to_controller = {
                'cart_id' => cart_id,
                'hmac' => hmac,
                'urlencodedhmac' => urlencodedhmac,
                'purchase_url' => purchase_url,
                'cart_item_id' => cart_item_id
            }
        end

        response_to_controller['is_valid'] = is_valid

        return response_to_controller
    end


# remove item from cart, eventually add the ability to adjust quantites here
    def modify_cart (params)
        request_params = {
            'Service' => @service,
            'Operation' => 'CartModify',
            'CartId' => params['cart']['id'],
            'HMAC' => params['cart']['hmac'],
            'URLEncodedHMAC' => params['cart']['urlencodedhmac'],
            'AWSAccessKeyId' => @access_key_id,
            'AssociateTag' => @associate_tag,
            'Item.1.CartItemId' => params['item']['cart_item_id'],
            'Item.1.Quantity' => params['item']['qty'],
            'ResponseGroup' => 'Cart'
        }

        # create signed url with all data
        signed_url = self.create_url(request_params)

        # make call to api
        response_from_aws = Nokogiri::HTML(open(signed_url))

        # grab error messages from nokogiri object
        errors = response_from_aws.xpath("//errors").text
        is_valid = response_from_aws.xpath("//isvalid").text

        # send response
        return is_valid
    end


    # needs to be incorporated for an eventual 'reset' button
    def clear_cart (params)
    end



    # helper method, used by other methods to create signed URL
    def create_url (params)
        # Set timestamp if not already set
        params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")

        # Generate the canonical query
        canonical_query_string = params.sort.collect do |key, value|
            [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
        end.join('&')


        # Generate the string to be signed
        string_to_sign = "GET\n#{@endpoint}\n#{@uri}\n#{canonical_query_string}"


        # Generate the signature required by the Product Advertising API
        signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @secret_key, string_to_sign)).strip()

        # Generate the signed URL
        signed = "http://#{@endpoint}#{@uri}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

        return signed
    end
end
