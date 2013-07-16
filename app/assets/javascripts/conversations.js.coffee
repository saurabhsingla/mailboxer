# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
	$('#conversations').dataTable({

	sPaginationType: "full_numbers"
	bJQueryUI: true
	"aoColumnDefs": [
      { "bVisible": false, "aTargets": [ 3 ] }
      { "bSortable": false, "aTargets": [ 0,4 ] }
      { "bSearchable": false, "aTargets": [ 4 ] }       
    ]
   
	});