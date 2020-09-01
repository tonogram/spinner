import fidget, spinner, fidget/opengl/base

import random
randomize()
from sequtils import filterIt

const x = [
  (("#70bdcf", "#70bdcf", "#e5f7fe"), ("#9fe7f8", "#9fe7f8", "#e5f7fe")),
  (("#B170CF", "#B170CF", "#F9E5FE"), ("#DC9FF8", "#DC9FF8", "#F9E5FE")),
  (("#CF8270", "#CF8270", "#FEECE5"), ("#F8B09F", "#F8B09F", "#FEECE5")),
  (("#8ECF70", "#8ECF70", "#EBFEE5"), ("#BBF89F", "#BBF89F", "#EBFEE5"))
]

loadFont("Roboto", "Roboto-Regular.ttf")

var a: tuple[left, handle, right: string]
var b: tuple[left, handle, right: string]
(a, b) = sample(x)

proc changeColors() =
  let y = x.filterIt(it != (a, b))
  (a, b) = sample(y)
    
proc drawMain() =
  group "horizontal":
    box 50, 50, 200, 36
    createSlider("hA", 0, 0, 200, 0.5, idleColors=a, hoverColors=b, style=sliderA)
    createSlider("hB", 0, 24, 200, 0.5, idleColors=a, hoverColors=b, style=sliderB)
  group "vertical":
    box 50, 100, 36, 200
    createSlider("vA", 0, 0, 200, 0.5, idleColors=a, hoverColors=b, style=sliderA, direction=Vertical)
    createSlider("vB", 24, 0, 200, 0.5, idleColors=a, hoverColors=b, style=sliderB, direction=Vertical)
  group "buttons":
    box 100, 100, 120, 120
    createButton("button1", 0, 0, 120, 30, "change colors", ("Roboto", 16.0, 400.0), idleColors=(a.left, a.right), hoverColors=(b.left, "#FFFFFF"), style=buttonA, action=changeColors)
    createButton("button2", 0, 45, 120, 30, "change colors", ("Roboto", 16.0, 400.0), idleColors=(a.left, a.right), hoverColors=(b.left, "#FFFFFF"), style=buttonB, action=changeColors)
    createButton("button3", 0, 90, 120, 30, "change colors", ("Roboto", 16.0, 400.0), idleColors=(a.left, a.right), hoverColors=(b.left, "#FFFFFF"), style=buttonC, action=changeColors)
      

startFidget(draw=drawMain, w=800, h=600, mainLoopMode=RepaintOnFrame)
