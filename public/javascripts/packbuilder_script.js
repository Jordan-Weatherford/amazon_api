var slide_index = 0;
var catagory = gon.items[Object.keys(gon.items)[0]][0]['catagory'];  // get first catagory in gon.items
var equipped = {
    'total_weight': 0,
    'total_price': 0
};
var current_item = gon.items[catagory][slide_index];
var cart = {};


$(document).ready(function(){
    PopulateChartData();
    PopulateSlideData();
    PopulateCatagories();
    ThumbClicked();
    ArrowClicked();
    CatagoryClicked();
    EquipItemChecked();
    Intro();
});

$(window).resize(function(){
});

function Intro(){
    var intro = introJs();

    intro.oncomplete(function(){
        $('#equip_item_checkbox').prop('checked', false).triggerHandler('click');
    });

    intro.onexit(function(){
        $('#equip_item_checkbox').prop('checked', false).triggerHandler('click');
    });

    intro.onchange(function(targetElement){
        console.log(targetElement.id);
        if (targetElement.id == 'equip_item_checkbox'){
            $('#equip_item_checkbox').prop('checked', true).triggerHandler('click');
        };
    });

    intro.setOptions({
        steps: [
            {
                intro: "Welcome to the Loadout Tool !",
                position: 'top'
            },
            {
                element: '#catagory_wrapper',
                intro: "Select Catagory",
                position: 'left'
            },
            {
                element: '.right',
                intro: "Scroll through recommended items",
                position: "top"
            },
            {
                element: '#equip_item_checkbox',
                intro: "equip what you wanna carry",
                position: "right"
            },
            {
                element: '#chart_wrapper',
                intro: 'see your custom pack stats',
                position: 'right'
            },
            {
                element: '#purchase_cart_img',
                intro: 'add to amazon cart!',
                position: 'top'
            }
        ]
    }).start();

};



// function EquipExample(targetElement){
//     console.log(targetElement);
    // switch (targetElement.id) {
    //     case "step1":
    //         console.log(targetElement.id);
    //     break;
    //     case "step2":
    //         console.log(targetElement.id);
    //         break;
    //
    //     case "step3":
    //         console.log(targetElement.id);
    //         break;
    //     default:

    // }
    // $('#equip_item_checkbox').attr('checked', true).triggerHandler('click');
// };










function DeleteFromCart(params){
    var request_params = {
        'item': {
            'cart_item_id': params['cart_item_id'],
            'qty': params['qty']
        },

        'cart': {
            'hmac': cart['hmac'],
            'urlencodedhmac': cart['urlencodedhmac'],
            'id': cart['id']
        }
    };

    $.get('/delete', request_params, function(response){
        console.log(response);
    });
};



function CreateCart(params){
    // ajax call to create cart
    var request_params = {
        'item': {
            'asin': params['asin'],
            'qty': params['qty']
        }
    };

    $.get('/create', request_params, function(response){
        // check if response is valid
        if (response['valid']){
            cart['id'] = response['cart_id'];
            cart['hmac'] = response['hmac'];
            cart['urlencodedhmac'] = response['urlencodedhmac'];
            cart['purchase_url'] = response['purchase_url'];

            // set cart purchase url
            $('#purchase_link').attr('href', response['purchase_url']);

            // find equipped item matching the asin and assign it's 'cart_item_id' value
            $.each(equipped, function(cat, value){
                if (cat == 'total_price' || cat == 'total_weight'){
                    return;
                };

                for (var i = 0; i < value['items'].length; i++){
                    // proper item found. set it's 'cart item id' value
                    if (equipped[cat]['items'][i]['asin'] == params['asin']){
                        equipped[cat]['items'][i]['cart_item_id'] = response['cart_item_id'];
                    };
                };
            });

        } else {
        // handle errors here
            console.log('errors in response from api call to my backend and/or from backend to aws api!');
        };
    });
};

function AddToCart(params){
    var request_params = {
        'item': {
            'asin': params['asin'],
            'qty': params['qty']
        },
        'cart': {
            'id': cart['id'],
            'hmac': cart['hmac'],
            'urlencodedhmac': cart['urlencodedhmac']
        }
    };

    $.get('/add', request_params, function(response){
        // update purchase link
        cart['purchase_url'] = response['purchase_url'];

        // set cart purchase url
        $('#purchase_link').attr('href', response['purchase_url']);


        // find equipped item matching the asin and assign it's 'cart_item_id' value
        $.each(equipped, function(cat, value){
            if (cat == 'total_price' || cat == 'total_weight'){
                return;
            };

            for (var i = 0; i < value['items'].length; i++){
                // proper item found. set it's 'cart item id' value
                if (equipped[cat]['items'][i]['asin'] == params['asin']){
                    equipped[cat]['items'][i]['cart_item_id'] = response['cart_item_id'];
                };
            };
        });
    });
};












function PopulateEquippedItems(){
// hide data output objects if no items are equipped, show otherwise
    var keys = Object.keys(equipped);

    if (keys.length < 3){
        $('#pack_data_wrapper').css('display', 'none');
    } else {
        $('#pack_data_wrapper').css('display', 'inline-block');

        // delete all old equipped items
        $('.single_item_wrapper').remove();


        $.each(equipped, function(key, value){
            if (key == 'total_weight' || key == 'total_price'){
                return;
            } else {
                $.each(value['items'], function(index, item){
                    var url = item['images']['thumbnail_imageset'][0]['url'];
                    var height = item['images']['thumbnail_imageset'][0]['height'];
                    var width = item['images']['thumbnail_imageset'][0]['width'];
                    var aspect_ratio = width / height;


                    // portrait
                    if (aspect_ratio < 1){
                        var adjusted_width = (55 * aspect_ratio).toFixed(2);

                        $('#purchase_cart_img').before(
                            '<a href="'+ item['link'] + '" target="_blank">' +
                                '<div class="single_item_wrapper">' +
                                    '<div class="equipped_item_thumbnail_wrapper" name="' + item['nickname'] + '">' +
                                        '<img src="' + url + '" alt="thumbnail image" height="55px" width="' + adjusted_width + 'px">' +
                                    '</div>' +
                                    '<h1 class="equipped_item_nickname">' + item['nickname'] + '</h1>' +
                                '</div>' +
                            '</a>'
                        );
                    // landscape or square
                    } else {
                        var adjusted_height = (55 / aspect_ratio).toFixed(2);
                        var adjusted_margin = (55 - adjusted_height) / 2;

                        $('#purchase_cart_img').before(
                            '<div class="single_item_wrapper">' +
                                '<a href="' + item['link'] + '" target="_blank"><div class="equipped_item_thumbnail_wrapper" name="' + item['nickname'] + '" value="' + item['link'] + '"></a>' +
                                    '<img src="' + url + '" alt="thumbnail image" height="' + adjusted_height + '" width="55px" style="margin-top: ' + adjusted_margin.toFixed(2) + 'px">' +
                                '</div>' +
                                '<h1 class="equipped_item_nickname">' + item['nickname'] + '</h1>' +
                            '</div>'
                        );
                    };
                });
            };
        });
    };
};



function PopulateChartData(){
    PopulateEquippedItems();

    // format chart data
    var temp_array = [];

    $.each(equipped, function(index, catagory){
        // skip totals
        if (index == 'total_weight' || index == 'total_price'){
            return;
        };

        var temp_obj = {
            'weight': catagory['weight'],
            'color': catagory['color'],
            'label': index
        };

        temp_array.push(temp_obj);


    });

    // sort data descending by weight
    var sorted_data = SortItemsDescending(temp_array);
    var sorted_data_array = [];
    var sorted_colors_array = [];
    var sorted_labels_array = [];

    $.each(sorted_data, function(index, obj){
        sorted_data_array.push(obj['weight']);
        sorted_colors_array.push(obj['color']);
        sorted_labels_array.push(obj['label']);
    });

    // instantiate chart and pass in sorted data
    var new_chart = document.getElementById("chart_canvas").getContext('2d');

    var equipped_item_data = {
        datasets: [{
            data: sorted_data_array,
            backgroundColor: sorted_colors_array,
        }],

        labels: sorted_labels_array,
    };


    // create a new chart only if necessary, otherwise just update data
    if (!myDoughnutChart){
        var myDoughnutChart = new Chart(new_chart, {
            type: 'doughnut',
            data: equipped_item_data
        });
    } else {
        myDoughnutChart.chart.data = equipped_item_data;
        myDoughnutChart.update;
    };


    // format price and weight total
    var formatted_price = equipped['total_price'].toFixed(2);
    var weight_in_pounds = parseFloat(equipped['total_price'] / 16);
    var formatted_weight_in_pounds = weight_in_pounds.toFixed(2);


    // set data output html
    $('#total_weight').html(formatted_weight_in_pounds + " lbs");
    $('#total_price').html("$" + formatted_price);
};


function SortItemsDescending(myArray){
    var sorted_array = [];
    var swapped;

    do {
        swapped = false;
        var idx = 0;

        while (idx < myArray.length - 1){
            // make swap, set flag to equal 'true'
            if (myArray[idx]['weight'] < myArray[idx + 1]['weight']){
                var temp = myArray[idx];
                myArray[idx] = myArray[idx + 1];
                myArray[idx + 1] = temp;
                swapped = true;
            };
            idx += 1;
        };
    } while (swapped);
    return myArray;
};



function EquipItemChecked(){
    $('#equip_item_checkbox').on('click', function(){
        var item = $('#equip_item_checkbox').attr('value');
        var index = item.match(/\d+/);
        var cat = item.match(/[a-z]+/);
        item = gon.items[cat][index];
        var item_price_string = item['price'].match(/[0-9]*[.][0-9]*/)[0];
        var item_price = parseFloat(item_price_string);
        var item_weight = item['weight'];


        // checked
        if ($(this).prop('checked')){
            // // adjust css
            // $('#content_wrapper').css('text-align', 'left');
            //



            // add new item to totals
            equipped['total_weight'] = parseFloat(equipped['total_weight']) + item_weight;
            equipped['total_price'] = parseFloat(equipped['total_price']) + item_price;

            // create catagory and weight total if required
            if (!equipped[cat]){
                equipped[cat] = {};
                equipped[cat]['items'] = [];
                equipped[cat]['weight'] = 0;
            };

            equipped[cat]['items'].push(item);
            equipped[cat]['weight'] += item['weight'];


            // hardcoded catagory colors. replace this ish and store the value in the database upon item creation
            switch (cat[0]) {
                case 'packs':
                    equipped[cat]['color'] = 'blue';
                    break;

                case 'shelters':
                    equipped[cat]['color'] = 'orange';
                    break;

                case 'insulation':
                    equipped[cat]['color'] = 'green';
                    break;

                case 'kitchen':
                    equipped[cat]['color'] = 'yellow';
                    break;

                case 'safety':
                    equipped[cat]['color'] = 'red';
                    break;

                case 'hygiene':
                    equipped[cat]['color'] = 'pink';
                    break;

                case 'misc':
                    equipped[cat]['color'] = 'grey';
                    break;

                default:
                    break;
            };

            // make call to create or add cart
            var params  = {
                'asin': item['asin'],
                'qty': 1
            };

            if (!cart['id']){
                // cart exists, add item
                CreateCart(params);

            } else {
                // cart doesn't exist, create one
                AddToCart(params);
            };

        // unchecked
        } else {
            // correct weight totals
            equipped['total_weight'] = parseFloat(equipped['total_weight']) - item['weight'];
            equipped['total_price'] = parseFloat(equipped['total_price'] - item_price);

            if (equipped[cat]){
            equipped[cat]['weight'] -= item['weight'];
            };

            // remove item from equipped array
            for (var i = 0; i < equipped[cat]['items'].length; i++){
                if (equipped[cat]['items'][i]['id'] == item['id']){
                    equipped[cat]['items'].splice(i, 1);
                };
            };

            // catagory emptied out. delete.
            if (equipped[cat]['items'].length < 1){
                delete equipped[cat];
            };

            // remove item from cart
            var params  = {
                'cart_item_id': item['cart_item_id'],
                'qty': 0
            };

            DeleteFromCart(params);
        };
        PopulateChartData();
    });
};



function CatagoryClicked(){
    $('.catagory').on('click', function(){
        // do nothing if clicked on current catagory
        if (catagory == $(this)[0].innerHTML){
            return;
        };

        // add 'catagory_selected' class to clicked catagory
        $('.catagory').addClass('white');
        $('.catagory').removeClass('yellow');

        $(this).removeClass('white');
        $(this).addClass('yellow');

        // change JS 'catagory' variable, then update slide
        catagory = $(this)[0].innerHTML;

        PopulateSlideData();
    });

    // initialize first catagory as being selected
    $($('.catagory')[0]).addClass('yellow');
    $($('.catagory')[0]).removeClass('white');
};

function PopulateCatagories(){
    $.each(gon.items, function(key, value){
        var item_count = Object.keys(gon.items).length;

        $('#catagory_wrapper').append(
            "<p class='catagory white' style='height: " + (500 / item_count) + "px; line-height: " + (500 / item_count) + "px;'>" + key + "</p>"
        );
    });
};

function ArrowClicked(){
    $('.arrow').on('click', function(){
        if ($(this).attr('name') == 'left'){
            if (slide_index > 0){
                slide_index -= 1;
            } else {
                slide_index = gon.items[catagory].length - 1;
            };
        } else {
            if (slide_index < gon.items[catagory].length - 1){
                slide_index += 1;
            } else {
                slide_index = 0;
            };
        };
        PopulateSlideData();
    });
};


function PopulateSlideData(){
    // update current item
    current_item = gon.items[catagory][slide_index];

    // set item title, price, weight, description
    $('#item_header').html(current_item['nickname']);
    $('#item_weight').html(current_item['weight']);
    $('#item_price').html(current_item['price']);
    $('#item_description').html(current_item['description']);

    // set all slide links
    var link = gon.items[catagory][slide_index]['link'];

    $('.item_view_link').attr('href', link);


    // clear previous thumbnails
    $('#thumbnails_wrapper').empty();

    // set thumbnails
    var image_array = current_item['images'];
    var i = 0;


    // loop through images, set thumbnails. stop at 6
    while (i < image_array['thumbnail_imageset'].length && i < 6){
        var url = image_array['thumbnail_imageset'][i]['url'];
        var width = image_array['thumbnail_imageset'][i]['width'];
        var height = image_array['thumbnail_imageset'][i]['height'];
        var aspect_ratio = width / height;

        // append html
        $('#thumbnails_wrapper').append(
            "<div class='thumb_wrapper box_shadow'>" +
                "<img class='thumb_image' name='" + i + "' src='" + url + "' alt='thumb'>" +
            "</div>"
        );

        // portrait
        if (aspect_ratio < 1){
            // calculate image width
            var thumb_width = (45 * aspect_ratio).toFixed(2);

            // set CSS
            $(".thumb_image[name='" + i + "']").css({
                'height': '45px',
                'width': thumb_width + 'px'
            });

        // landscape and square images
        } else {
            var thumb_height = (45 / aspect_ratio).toFixed(2);
            var thumb_margin = (45 - thumb_height) / 2;

            // set css
            $(".thumb_image[name='" + i + "']").css({
                'width': '45px',
                'height': thumb_height + 'px',
                'margin-top': thumb_margin + 'px'
            });
        };
        // increment! no inifinite loops pls!
        i += 1;
    };
    // main image url
    var main_image = current_item['images']['large_imageset'][0];
    var aspect_ratio = main_image['width'] / main_image['height'];

    // set main image, it's css and it's anchor tags href
    $('#main_image').attr('src', main_image['url']);
    $('#main_image').parent().attr('href', current_item['link'])

    // add selected class to first thumbnail
    $($('.thumb_wrapper')[0]).addClass('thumb_selected');
    $($('.thumb_wrapper')[0]).removeClass('box_shadow');

    // check image orientation and set it's css
    if (aspect_ratio < 1){
        // portrait
        var adjusted_width = 369 * aspect_ratio;

        $('#main_image').css({
            'width': adjusted_width + 'px',
            'height': '369px',
            'margin-top': '0'
        });

    } else {
        // landscape or square, needs a top margin for vertical centering
        var adjusted_height = 300 * aspect_ratio;
        var adjusted_margin = (369 - adjusted_height) / 2;

        $('#main_image').css({
            'width': '300px',
            'height': adjusted_height.toFixed(2) + 'px',
            'margin-top': adjusted_margin.toFixed(2) + 'px'
        });
    };


    // set checkbox value to 'catagory' + 'slide_index' for item reference, also check or uncheck accordingly
    $('#equip_item_checkbox').attr('value', catagory + slide_index);
    $('#equip_item_checkbox').prop('checked', false);

    $.each(equipped[catagory], function(index, items_array){
        if (index == 'items'){
            $.each(items_array, function(key, value){
                if (value['asin'] == current_item['asin']){
                    $('#equip_item_checkbox').prop('checked', true);
                };
            });
        };
    });

    // re-call thumbclicked function to re-add click event to thumbnails that are deleted and re-made with each slide change
    ThumbClicked();
};



function ThumbClicked(){
    // add click event to thumb_wrappers
    // grab thumbnail with class 'thumb_selected', get child element, get src, set to main img src
    $('.thumb_wrapper').on('click', function(){
        // remove selected class from all wrappers
        $('.thumb_wrapper').removeClass('box_shadow');
        $('.thumb_wrapper').addClass('box_shadow');
        $('.thumb_wrapper').removeClass('thumb_selected');

        // add class to clicked thumb_margin
        $(this).addClass('thumb_selected');
        $(this).removeClass('box_shadow');

        // change main picture src
        var index = $(this)[0].children[0]['name'];
        var image = gon.items[catagory][slide_index]['images']['large_imageset'][index];

        $('#main_image').attr('src', image['url']);

        // set main image css
        var aspect_ratio = image['width'] / image['height'];

        // check image orientation and set it's css
        if (aspect_ratio < 0.897){
            // portrait
            var adjusted_width = (369 * aspect_ratio).toFixed(2);
            $('#main_image').css({
                'width': adjusted_width + 'px',
                'height': '369px',
                'margin-top': '0'
            });

        } else {
            // landscape or square
            var adjusted_height = (300 / aspect_ratio).toFixed(2);
            var adjusted_margin = (369 - adjusted_height) / 2;

            $('#main_image').css({
                'width': '300px',
                'height': adjusted_height + 'px',
                'margin-top': adjusted_margin.toFixed(2) + 'px'
            });
        };
    });
};
