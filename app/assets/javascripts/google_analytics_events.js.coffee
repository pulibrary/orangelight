$ ->
  # Track if user is clicking on stack map pin icon in results page
  $('#documents .find-it').on 'click', ->
    ga('send', 'event', 'Availability', 'Search Results', 'StackMap Pin')

  # Track if user is clicking on stack map pin icon in show page
  $('#availability .find-it').on 'click', ->
    ga('send', 'event', 'Availability', 'Item Record', 'StackMap Pin')
