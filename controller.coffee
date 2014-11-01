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
        xacceleration: _.random(-3, 3) + _.random(-3, 3) + _.random(-3, 3) # uniform random
        yacceleration: _.random(-15, -3)
      $scope.drops++;


.factory 'CanvasDrawing', () ->
  canvas = document.getElementById 'canvas'
  ctx = new Context2DWrapper canvas.getContext '2d'

  drops = []
  moveDrop = (drop) ->
    ctx.drawImage drop.img, drop.x, drop.y, drop.w, drop.h
    drop.yacceleration += 1
    drop.y += drop.yacceleration
    drop.xacceleration /= 1.03
    drop.x += drop.xacceleration
    drop.y < 700

  prevTime = 0
  render = (time) ->
    timeDiff = time - prevTime;
    prevTime = time;

    ctx.clearRect 0, 0, canvas.width, canvas.height

    drops = _.filter drops, moveDrop
    console.log drops.length, timeDiff, time

  animloop = (time) ->
    requestAnimationFrame animloop
    render(time)
  animloop(0)

  return {
    addDrop: (obj) -> drops.push obj
  }
