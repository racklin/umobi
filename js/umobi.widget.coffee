###
//>>excludeStart("umobiBuildExclude", pragmas.umobiBuildExclude)
###
define ["jquery","cs!umobi.core","cs!u"], () ->
  ###
  //>>excludeEnd("umobiBuildExclude")
  ###
  $ ->
    inputs = u.dom.queryAll('input, textarea')
    for input in inputs
      $input = $(input)

      if input.type is "text" or input.type is "password"
        uiClass = "ui-input-text"
        input.className += uiClass
        $input.wrap('<div class="' + uiClass + ' ui-shadow-inset ui-corner-all ui-btn-shadow ui-body-c"></div>')
        $input.focus -> $(this).parent().addClass('ui-focus')
        $input.blur -> $(this).parent().removeClass('ui-focus')
        $input.parent().addClass("ui-mini") if $input.data("mini")
      else if input.nodeName is "TEXTAREA"
        input.className += "ui-input-text ui-shadow-inset ui-corner-all ui-btn-shadow ui-body-c"
        $input.focus -> $(this).addClass('ui-focus')
        $input.blur -> $(this).removeClass('ui-focus')
        $input.parent().addClass("ui-mini") if $input.data("mini")

  ###
  //>>excludeStart("umobiBuildExclude", pragmas.umobiBuildExclude)
  ###
  #        $input.on 'touchmove', (e) ->
  #          e.stopPropagation()
  #          e.stopImmediatePropagation()
  #        $input.on 'touchstart', (e) ->
  #          e.stopPropagation()
  #          e.stopImmediatePropagation()
  return
###
//>>excludeEnd("umobiBuildExclude")
###
