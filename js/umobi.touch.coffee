###
//>>excludeStart("umobiBuildExclude", pragmas.umobiBuildExclude)
###
define ["jquery","cs!umobi.core","cs!u"], () ->
  ###
  //>>excludeEnd("umobiBuildExclude")
  ###

  class TapDetector
    moved: false
    constructor: (@element) ->
      @element.addEventListener "touchstart", this ,false

    handleEvent: (e) ->
      switch e.type
        when "touchmove"  then @onTouchMove(e)
        when "touchstart" then @onTouchStart(e)
        when "touchend"   then @onTouchEnd(e)


    # touch event reference:
    #   1. http://stackoverflow.com/questions/5713393/creating-and-firing-touch-events-on-a-touch-enabled-browser
    #   2. Tap: http://css-infos.net/property/-webkit-tap-highlight-color
    #   3. WebKit: http://cubiq.org/remove-onclick-delay-on-webkit-for-iphone
    #   4. Safari: http://developer.apple.com/library/ios/#documentation/AppleApplications/Reference/SafariWebContent/HandlingEvents/HandlingEvents.html
    onTouchStart: (e) ->
      @moved = false
      @theTarget = document.elementFromPoint(e.targetTouches[0].clientX, e.targetTouches[0].clientY)
      @_t = setTimeout((=>
        # $(@theTarget).trigger("mousedown")
      ),200)
      @element.addEventListener "touchmove", this, false
      @element.addEventListener "touchend", this, false

    onTouchMove: (e) ->
      @moved = true
      clearTimeout(@_t)

    onTouchEnd: (e) ->
      @element.removeEventListener "touchmove", this, false
      @element.removeEventListener "touchend", this, false
      if not @moved && @theTarget
        # @theTarget.className = this.theTarget.className.replace(/ ?pressed/gi, '')
        # click = document.createEvent("MouseEvents")
        # click.initEvent('tap', true, true)
        # @theTarget.dispatchEvent(click)

        # XXX: we should use lighter event handler/trigger.
        # and which should be compatible with DOM's addEventListener() function.
        $(@theTarget).trigger("tap")

  u.ready ->
    $("a,button").each (i,e) ->
      new TapDetector(this)

  ###
  //>>excludeStart("umobiBuildExclude", pragmas.umobiBuildExclude)
  ###
  return
###
//>>excludeEnd("umobiBuildExclude")
###
