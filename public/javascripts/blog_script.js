$(document).ready(function(){
    StartMasonryImageGrid();
});


$(window).resize(function(){
});


function StartMasonryImageGrid(){
    // init Masonry
    var $grid = $('.grid').masonry({
    // options...
        itemSelector: '.grid-item',
        percentPosition: true,
        columnWidth: '.grid-sizer',
        horizontalOrder: true
    });

    // layout Masonry after each image loads
    $grid.imagesLoaded(function() {
        $grid.masonry('layout');
    });
};
