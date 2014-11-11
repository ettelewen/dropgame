'use strict';

angular.module 'clickingGame', ['ui.bootstrap']
.controller 'RootCtrl', ($scope, $timeout, $interval, CanvasDrawing) ->
  $scope.drops = 0

  $scope.$watch 'drops', (drops) ->
    document.title = drops + ' drops' if $scope.drops > 0

  CanvasDrawing.onDrops (numDrops) ->
    $scope.drops += numDrops
    $scope.$digest()


  $scope.dropImgFiles = ['tint_1.png', 'tint_2.png', 'tint_3.png']
  dropImages = []
  $timeout () -> dropImages = $('.drops .drop')

  getXY = (event) ->
    x: event.pageX - $(event.target).offset().left
    y: event.pageY - $(event.target).offset().top

  $scope.userClick = 1
  $scope.canvasClick = ($event) ->
    pt = getXY $event
    _.times Math.round(_.normalRandom($scope.userClick, $scope.userClick*0.3)), () ->
      size = _.normalRandom(40, 20)
      CanvasDrawing.addDrop
        img: _.sample(dropImages, 1)[0]
        x: pt.x - size/2
        y: pt.y - size/3
        w: size
        h: size
        xspeed: _.normalRandom(0, 10)
        yspeed: _.normalRandom(-9, 6)
        yacceleration: 1

  $scope.canvasMove = ($event) -> null

  $scope.buyClicker = (clicker) ->
    return if $scope.drops < clicker.price
    $scope.drops -= clicker.price
    if clicker.bought >= 1
      clicker.upgrade(clicker)
    clicker.bought++
    clicker.buy(clicker)


  $scope.autoclickers = []
  CanvasDrawing.onMove (movedt) ->
    _.each $scope.autoclickers, (clicker) ->
      return if clicker.bought <= 0
      return if clicker.every <= 0

      clicker.has += movedt
      while clicker.has > clicker.every
        clicker.do(clicker)
        clicker.has -= clicker.every


  $scope.autoclickers.push
    text: 'Leaking ceiling'
    bought: 0
    has: 0
    every: 3000
    price: 100
    buy: (clicker) ->
      clicker.price *= 2
    upgrade: (clicker) ->
      clicker.drops++
    drops: 1
    do: (clicker) ->
      _.times Math.round(_.normalRandom(clicker.drops, clicker.drops*0.3)), () ->
        size = _.normalRandom(20, 10)
        CanvasDrawing.addDrop
          img: _.sample(dropImages, 1)[0]
          x: _.normalRandom(CanvasDrawing.width()/2, CanvasDrawing.width()/2) - size/2
          y: 10 - size/3
          w: size
          h: size
          xspeed: 0
          yspeed: _.normalRandom(0, 3)
          yacceleration: 1

  $scope.autoclickers.push
    text: 'Open rooftop'
    bought: 0
    has: 0
    every: 30
    price: 2000
    buy: (clicker) ->
      clicker.price *= 3
    upgrade: (clicker) ->
      clicker.every *= 0.70
    do: (clicker) ->
      size = _.normalRandom(10, 5)
      CanvasDrawing.addDrop
        img: _.sample(dropImages, 1)[0]
        x: _.random(0, CanvasDrawing.width()) - size/2
        y: 10 - size/3
        w: size
        h: size
        xspeed: 0
        yspeed: _.normalRandom(0, 3)
        yacceleration: 1

  $scope.miscupgrades = []
  $scope.miscupgrades.push
    text: 'Double clicks'
    bought: 0
    price: 200
    buy: (clicker) ->
      $scope.userClick++
      clicker.removed = true

  $scope.miscupgrades.push
    text: 'Move clicks'
    bought: 0
    price: 200
    buy: (clicker) ->
      $scope.canvasMove = _.throttle ($event) ->
        $scope.canvasClick $event
      , 100
      clicker.removed = true




.filter 'notRemoved', () ->
  (clickers) -> _.reject clickers, {removed: true}



.factory 'CanvasDrawing', () ->
  canvas = document.getElementById 'canvas'
  ctx = new Context2DWrapper canvas.getContext '2d'
  $(window).on 'resize', ->
    $(canvas).attr
      height: 0
    $(canvas).attr
      width: $(canvas).parent().width()
      height: $(canvas).parent().height() - $(canvas).offset().top
  $(window).trigger('resize')

  drops = []
  dropsRemoved = (num) -> null
  move_dt = (movedt) -> null

  moveDrop = (drop) ->
    drop.y = drop.y + drop.yspeed
    drop.yspeed = drop.yspeed + drop.yacceleration
    drop.xspeed = drop.xspeed/1.03
    drop.x += drop.xspeed
    drop.y < canvas.height

  movedt = 1000/60
  accumulator = 0 # http://gafferongames.com/game-physics/fix-your-timestep/
  currTime = false
  render = (time) ->
    currTime = time if !currTime
    dt = time - currTime;
    currTime = time;
    accumulator += dt

    while accumulator > movedt
      prevNumDrops = drops.length
      drops = _.filter drops, moveDrop
      accumulator -= movedt

      dropsRemoved(prevNumDrops - drops.length)
      move_dt(movedt)


    ctx.clearRect 0, 0, canvas.width, canvas.height
    _.each drops, (drop) ->
      ctx.drawImage drop.img, drop.x, drop.y, drop.w, drop.h


  animloop = (time) ->
    requestAnimationFrame animloop
    render(time)
  animloop(0)

  return {
    addDrop: (obj) -> drops.push obj
    onDrops: (fn) -> dropsRemoved = fn
    onMove: (fn) -> move_dt = fn
    width: () -> canvas.width
    height: () -> canvas.height
  }


_.mixin
  normalRandom: (middle, delta) -> # normally distributed random
    [min, max] = [middle-delta, middle+delta]
    (_.random(min, max) + _.random(min, max) + _.random(min, max))/3
