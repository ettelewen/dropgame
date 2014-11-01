'use strict';

angular.module 'clickingGame', []
.controller 'RootCtrl', ($scope, $timeout, CanvasDrawing) ->
  $scope.drops = 0

  CanvasDrawing.onDrops (numDrops) ->
    $scope.drops += numDrops
    $scope.$digest()


  $scope.dropImgFiles = ['tint_1.png', 'tint_2.png', 'tint_3.png']
  dropImages = []
  $timeout () -> dropImages = $('.drops .drop')

  getXY = (event) ->
    if event.offsetX == null # Firefox
      {x: event.originalEvent.layerX, y: event.originalEvent.layerY}
    else
      {x: event.offsetX, y: event.offsetY} # Other browsers

  $scope.canvasClick = ($event) ->
    pt = getXY $event
    _.times 10, () ->
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


.factory 'CanvasDrawing', () ->
  canvas = document.getElementById 'canvas'
  ctx = new Context2DWrapper canvas.getContext '2d'

  drops = []
  dropsRemoved = (num) -> null

  moveDrop = (drop) ->
    drop.y = drop.y + drop.yspeed
    drop.yspeed = drop.yspeed + drop.yacceleration
    drop.xspeed = drop.xspeed/1.03
    drop.x += drop.xspeed
    drop.y < 700

  movedt = 1000/60
  accumulator = 0 # http://gafferongames.com/game-physics/fix-your-timestep/
  currTime = 0
  render = (time) ->
    dt = time - currTime;
    currTime = time;
    accumulator += dt

    while accumulator > movedt
      prevNumDrops = drops.length
      drops = _.filter drops, moveDrop
      accumulator -= movedt

      dropsRemoved(prevNumDrops - drops.length)


    ctx.clearRect 0, 0, canvas.width, canvas.height
    _.each drops, (drop) ->
      ctx.drawImage drop.img, drop.x, drop.y, drop.w, drop.h

    console.log drops.length, dt, time

  animloop = (time) ->
    requestAnimationFrame animloop
    render(time)
  animloop(0)

  return {
    addDrop: (obj) -> drops.push obj
    onDrops: (fn) -> dropsRemoved = fn
  }


_.mixin
  normalRandom: (middle, delta) -> # normally distributed random
    [min, max] = [middle-delta, middle+delta]
    (_.random(min, max) + _.random(min, max) + _.random(min, max))/3
