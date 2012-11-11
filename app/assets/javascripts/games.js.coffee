# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(->
  $('#edit-game').css('visibility','hidden')
  $('.words').sortable(out:->alert('out'))
  $('.clear-tiles').bind('click', ->
    $('.words').html('')
    $('.tiles .tile').css('visibility','visible')
    $('#edit-game').css('visibility','hidden')
    $(".words .hint").show();
  )
	
  #$("#edit-game").bind('ajax:loading', -> alert("loading!"))
  $("#edit-game").bind('ajax:success', (data, status, xhr) -> $('#game').html(data))
  $("#edit-game").bind('ajax:failure', (xhr, status, error) -> alert("Unable to reach the server. Please try again later!"))
  #$("#edit-game").bind('ajax:complete', -> alert("complete!"))
	
  $('#tiles-signdin .tile').bind('click', ->
    $('.words').append($(this)[0].outerHTML)
    $(this).css('visibility','hidden')
    values = $('.words .tile').map(-> $(this).attr('data-id'))
    values_array = values.toArray()
    $('#sequence').val(values_array.join(","))
    $(".words .hint").hide();
    if (values_array.length > 1)
      $('#edit-game').css('visibility','visible')
    else
      $('#edit-game').css('visibility','hidden')
  )

  game_id = $("#game").attr('data-id')
  game_state = parseInt($("#game").attr('data-state'))

  PollingFunction = () ->
    $.ajax({
      url: '/games/'+game_id,
      dataType: 'json',
      type: 'GET',
      error: ->
        alert("Unable to reach server. Please reload the page.")
      success: (data,textStatus,jqXHR) ->
        if (game_state is data["state"])
          setTimeout(PollingFunction,10000)				
        else
          window.location = '/games/'+game_id+"?showMsg=1"
    })

  window.PollingFunction = PollingFunction
)
