import fidget, spinner, fidget/opengl/base

import random
randomize()
from sequtils import filterIt

const x = [
  (("#46607e", "#C1EEFA"), ("#5A8EA6", "#e5f7fe")),
  (("#48467E", "#C1D2FA"), ("#5A68A6", "#E5EBFE")),
  (("#64467E", "#CDC1FA"), ("#725AA6", "#ECE5FE")),
  (("#7E4660", "#FAC1EE"), ("#A65A8E", "#FEE5F7")),
  (("#607E46", "#EEFAC1"), ("#8EA65A", "#F7FEE5")),
  (("#467E64", "#C1FACD"), ("#5AA672", "#E5FEEC")),
  (("#467E64", "#C1FACD"), ("#5AA672", "#E5FEEC"))
]

loadFont("Roboto", "Roboto-Regular.ttf")

var i: tuple[a, b: string]
var h: tuple[a, b: string]
(i, h) = sample(x)

var prog = 0.0
var amt = 0.01

proc changeColors() =
  let y = x.filterIt(it != (i, h))
  (i, h) = sample(y)
    
proc drawMain() =
  group "tiny demo":
    box 36, 36, 136, 144
    createProgress("load_amnt", 0, 0, 144, prog, colors=(i.a, i.b), orientation=Vertical)
    createSlider("some_value", 36, 0, 108, 0.5, idleColors=(i.a, i.a, i.b), hoverColors=(h.a, h.a, h.b))
    createButton("perform_action", 36, 36, 108, 36, "change colors", ("Roboto", 12.0, 400.0), idleColors=(i.a, i.b), hoverColors=(h.a, h.b), action=changeColors)
    createToggle("change_setting", 36, 90, idleColors=(i.a, i.a, i.b), hoverColors=(h.a, h.a, h.b))
    createCheckbox("choose_something", 90, 90, idleColors=(i.a, i.b), hoverColors=(h.a, h.b))
    createCheckbox("choose_something_else", 126, 90, idleColors=(i.a, i.b), hoverColors=(h.a, h.b))
    createRadio("option1", "group1", 45, 126, idleColors=(i.a, i.b), hoverColors=(h.a, h.b))
    createRadio("option2", "group1", 81, 126, idleColors=(i.a, i.b), hoverColors=(h.a, h.b))
    createRadio("option3", "group1", 117, 126, idleColors=(i.a, i.b), hoverColors=(h.a, h.b))
  prog += amt
  if prog > 1.0: prog = 1.0; amt = -0.01
  if prog < 0.0: prog = 0.0; amt = 0.01

proc loadMain() = setTitle("Demo")

startFidget(draw=drawMain, load=loadMain, w=216, h=216, mainLoopMode=RepaintOnFrame)
