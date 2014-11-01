'use strict';

angular.module 'clickingGame', []
.controller 'RootCtrl', ($scope, $timeout, CanvasDrawing) ->
  $scope.drops = 0

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
    _.times 10000, () ->
      size = _.random(20, 64)
      CanvasDrawing.addDrop
        img: _.sample(dropImages, 1)[0]
        x: pt.x - size/2
        y: pt.y - size/3
        w: size
        h: size
        xspeed: _.random(-3, 3) + _.random(-3, 3) + _.random(-3, 3) # normally distributed random
        yspeed: _.random(-15, -3)
      $scope.drops++;


.factory 'CanvasDrawing', () ->
  canvas = document.getElementById 'canvas'
  ctx = new Context2DWrapper canvas.getContext '2d'

  drops = []

  yacceleration = 1
  moveDrop = (drop) ->
    drop.y = drop.y + drop.yspeed
    drop.yspeed = drop.yspeed + yacceleration
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
      drops = _.filter drops, moveDrop
      accumulator -= movedt

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
  }
