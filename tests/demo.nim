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

var prog = 0.0
var amt = 0.01

proc changeColors() =
  let y = x.filterIt(it != (a, b))
  (a, b) = sample(y)
    
proc drawMain() =
  group "tiny demo":
    box 36, 36, 136, 144
    createProgress("load_amnt", 0, 0, 144, prog, colors=(a.left, a.right), orientation=Vertical)
    createSlider("some_value", 36, 0, 108, 0.5, idleColors=a, hoverColors=b)
    createButton("perform_action", 36, 36, 108, 36, "change colors", ("Roboto", 12.0, 400.0), idleColors=(a.left, a.right), hoverColors=(b.left, "#FFFFFF"), action=changeColors)
    createToggle("change_setting", 36, 90, idleColors=(a.handle, a.right), hoverColors=(b.handle, b.right))
    createCheckbox("choose_something", 90, 90, idleColors=(a.right, a.left), hoverColors=(a.right, b.left))
    createCheckbox("choose_something_else", 126, 90, idleColors=(a.right, a.left), hoverColors=(a.right, b.left))
    createRadio("option1", "group1", 45, 126, idleColors=(a.right, a.left), hoverColors=(a.right, b.left))
    createRadio("option2", "group1", 81, 126, idleColors=(a.right, a.left), hoverColors=(a.right, b.left))
    createRadio("option3", "group1", 117, 126, idleColors=(a.right, a.left), hoverColors=(a.right, b.left))
  prog += amt
  if prog > 1.0: prog = 1.0; amt = -0.01
  if prog < 0.0: prog = 0.0; amt = 0.01

proc loadMain() = setTitle("Demo")

startFidget(draw=drawMain, load=loadMain, w=216, h=216, mainLoopMode=RepaintOnFrame)
