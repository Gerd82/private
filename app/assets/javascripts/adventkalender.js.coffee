# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->  
  fenster_position = =>
    height          = $(window).height()
    width           = $(window).width()
    fenster_height  = $('.fenster').height()
    fenster_width   = $('.fenster').width()
    space_col       = (width  - fenster_width*6) / 6
    space_row       = (height - fenster_height*4) / 4

    row             = 1
    col             = 0
    $.each $('.fenster'), (index, value) =>
      if col >= 6
        row        += 1
        col         = 0

      col          += 1

      $(value).css('left', (space_col/2) + (fenster_width*(col-1)) + (space_col*(col-1)))
      $(value).css('top',  (space_row/2) + (fenster_height*(row-1)) + (space_row*(row-1)))
      value.show

  fenster_position()


  $(window).resize ->  
    fenster_position()