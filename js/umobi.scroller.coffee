define ['jquery','cs!umobi.core'], ->

  debug = false

  $(->
    # TODO: range slider need this.
    document.body.addEventListener('touchmove', ((e) ->
      # This prevents native scrolling from happening.
      e.preventDefault()
    ), false)
  )

  class Scroller
    constructor: (@element) ->

      # first touch offset Y from touchstart event.
      @startTouchY = 0

      # last touch offset Y from touchmove event.
      @lastTouchY          = 0
      @contentStartOffsetY = 0
      @element.addEventListener('touchstart', this, false)
      @element.addEventListener('touchmove', this, false)
      @element.addEventListener('touchend', this, false)

    handleEvent: (e) ->
      switch e.type
        when "touchstart"
          @onTouchStart(e)
        when "touchmove"
          @onTouchMove(e)
        when "touchend"
          @onTouchEnd(e)

    onTouchStart: (e) ->
      @stopMomentum()
      @startTouchY = e.touches[0].clientY
      @startTouchTime = (new Date).getTime()
      @contentStartOffsetY = @getContentOffsetY()
      console.log( 'onTouchStart at', @startTouchY , 'Content start offset at', @contentStartOffsetY)

    onTouchMove: (e) ->
      return if not @isDragging
      console.log 'onTouchMove', { touchY: e.touches[0].clientY , contentStartOffsetY: @contentStartOffsetY }

      currentY    = e.touches[0].clientY
      deltaY      = currentY - @startTouchY
      newY        = deltaY   + @contentStartOffsetY
      @lastTouchY = currentY
      newY = 30 if newY > 30
      # @startTouchY = currentY
      # return
      @animateTo(newY)
      @contentLastOffsetY = newY

    onTouchEnd: (e) ->
      console.log 'onTouchEnd',e

      if @isDragging()
        if @shouldStartMomentum()
          @startMomentum()
        else
          @snapToBounds()

    getContentOffsetY: () ->
      style = document.defaultView.getComputedStyle(@element, null)
      transform = new WebKitCSSMatrix(style.webkitTransform)
      return transform.m42

    isDragging: () -> true

    animateTo: (offsetY) ->
      @contentOffsetY = offsetY

      # We use webkit-transforms with translate3d because these animations
      # will be hardware accelerated, and therefore significantly faster
      # than changing the top value.
      @element.style.webkitTransform = 'translate3d(0, ' + offsetY + 'px, 0)'

    getEndVelocity: -> (@contentLastOffsetY - @contentStartOffsetY) / ((new Date).getTime() - @startTouchTime)

    isDecelerating: -> true

    shouldStartMomentum: ->
      return true
      # @lastTouchY
      contentOffsetY = @getContentOffsetY()
      return false if contentOffsetY > 30
      return true

    stopMomentum: () ->
      if @isDecelerating()
        # Get the computed style object.
        style = document.defaultView.getComputedStyle(@element, null)
        # Computed the transform in a matrix object given the style.
        transform = new WebKitCSSMatrix(style.webkitTransform)
        # Clear the active transition so it doesn’t apply to our next transform.
        @element.style.webkitTransition = ''
        # Set the element transform to where it is right now.
        @animateTo(transform.m42)

    # Calculate the movement properties. Implement getEndVelocity using the
    # start and end position / time.
    calculateMomentum: () ->
      velocity = @getEndVelocity()
      acceleration = if velocity < 0 then 0.0005 else -0.0005
      displacement = - (velocity * velocity) / (2 * acceleration)
      time = - velocity / acceleration
      newY = @contentOffsetY + displacement
      return {
        velocity: velocity
        acceleration: acceleration
        displacement: displacement
        time: time
        newY: newY
      }

    startMomentum: () ->
      m = @calculateMomentum()

      # Set up the transition and execute the transform. Once you implement this
      # you will need to figure out an appropriate time to clear the transition
      # so that it doesn’t apply to subsequent scrolling.
      # @element.style.webkitTransition = '-webkit-transform ' + time + 'ms cubic-bezier(0.33, 0.66, 0.66, 1)'
      @element.style.webkitTransition = '-webkit-transform ' + m.time + 'ms cubic-bezier(0.33, 0.66, 0.66, 1)'
      @element.style.webkitTransform = 'translate3d(0,' + m.newY + 'px, 0)'
      @contentOffsetY = m.newY
      console.log "startMomentum", m

    snapToBounds: () ->
    

  umobi.scroller = {}
  umobi.scroller.create = (element) -> new Scroller(element)
