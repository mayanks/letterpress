# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(->
  $('#edit-game').hide()
  $('.words').sortable();
  $('#tiles-signdin .tile').bind('click', ->
    $('.words').append($(this)[0].outerHTML)
    $(this).css('visibility','hidden')
    values = $('.words .tile').map(-> $(this).attr('data-id'))
    values_array = values.toArray()
    $('#sequence').val(values_array.join(","))
    if (values_array.length > 1)
      $('#edit-game').show();
    else
      $('#edit-game').hide();
  )
)
