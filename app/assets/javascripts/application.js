// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
// require gridster
//= require shapeshifter
//= require genius
//= require_tree .


$(function(){
    // $(".gridster ul").gridster({
    //     widget_margins: [10, 10],
    //     widget_base_dimensions: [140, 140],
    //     serialize_params: function($w, wgd) { 
    //         return { 
    //                id: $($w).attr('id'), 
    //                col: wgd.col, 
    //                row: wgd.row, 
    //                size_x: wgd.size_x, 
    //                size_y: wgd.size_y 
    //         };
    //     },
    // });
    // var gridster = $(".gridster ul").gridster().data('gridster');
    // gridData = gridster.serialize();
    // gridster.add_widget(
    //   '<li class="new">The HTML of the widget...</li>', 2, 1
    // );
    // console.log(gridster.serialize())

  $('.container').shapeshift();
})
