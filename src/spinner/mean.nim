## Mean uses up a bit of extra performance and memory in exchange for a smoother
## look. Use Lean if you want significantly more lightweight versions of these
## components, at the cost of fidelity.

import fidget, gradient

import tables
from math import round

import types
export types

let TransFrames = (60/10).int
  ## Placeholder. Will be updated to use the display's refresh rate.

var Slider* = initTable[string, tuple[drag, hover: bool, pos: float]]()
  ## Public data for sliders.
var SliderImpl = initTable[string, tuple[t: int, left, handle, right: seq[Color], last: tuple[i, h: tuple[left, handle, right: string]], changed: bool]]()
  ## Private data for sliders. Probably bad for performance.
  ## 
  ## `t` stores how far along the color transition the slider should be.
  ## 
  ## `left, handle, right` each store the gradients used by the transition.
  ## 
  ## `last` stores the most recently applied colors, to allow for transitioning
  ##  between different color sets. `i` for `idleColors` and `h` for `hoverColors`.
  ## 
  ## `changed` is used to keep track of when the colors should be properly applied.

var Button* = initTable[string, tuple[hover: bool]]()
var ButtonImpl* = initTable[string, tuple[t: int, fill, text: seq[Color], last: tuple[i, h: tuple[fill, text: string]], changed: bool]]()

proc createSlider*(
  id: string,
  x, y, size: float,
  initPos: SliderRange = 0.0,
  idleColors: tuple[left, handle, right: string] = ("#70bdcf", "#70bdcf", "#e5f7fe"),
  hoverColors: tuple[left, handle, right: string] = ("#9fe7f8", "#9fe7f8", "#e5f7fe"),
  style: SliderStyle = sliderA, direction: SliderDirection = Horizontal
) =
  ## Creates a slider. Each slider must have a unique ID, otherwise it won't
  ## work quite right.
  ## 
  ## `x, y` for x and y coordinates respectively.
  ## 
  ## `width` for how long the slider should be horizontally.
  ## 
  ## `initPos` for how far along the slider the handle starts, in the range 0 to 1.
  ## Defaults to `0.0`.
  ## 
  ## `idleColors` and `hoverColors` change the colors of each part of the slider
  ## while it's either idle or hovered over respectively. The default colors are
  ## based on Fidget's IceUI demo.
  ## 
  ## `style` allows you to choose between different looks for the slider.

  # init in tables
  discard Slider.hasKeyOrPut(id, (false, false, initPos))
  discard SliderImpl.hasKeyOrPut(id,
    (
      0,
      linearGradient(idleColors.left.parseHtmlHex(), hoverColors.left.parseHtmlHex(), TransFrames),
      linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), TransFrames),
      linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), TransFrames),
      (idleColors, hoverColors), false
    )
  )

  group "slider":
    case direction
    of Horizontal:
      box x, y, size, 12
      # keep hovered color while dragging
      Slider[id].hover = Slider[id].drag
      # change color on hover
      onHover: Slider[id].hover = true
      # enable dragging on click
      onClick: Slider[id].drag = true
      # track position and mouse button
      if Slider[id].drag:
        Slider[id].drag = buttonDown[MOUSE_LEFT]
        Slider[id].pos = ((mouse.pos.x - current.screenBox.x) / size).clamp(0, 1.0)
      # switch for style
      case style
      of sliderA:
        rectangle "handle":
          box Slider[id].pos*(size-4), 0, 4, 12
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "left":
          box 0, 4, Slider[id].pos*size, 4
          fill SliderImpl[id].left[SliderImpl[id].t]
        rectangle "right":
          box 0, 4, size, 4
          fill SliderImpl[id].right[SliderImpl[id].t]
      of sliderB:
        rectangle "handle":
          box Slider[id].pos*(size-12), 0, 12, 12
          cornerRadius 6
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "left":
          box 4, 4, Slider[id].pos*(size-8), 4
          fill SliderImpl[id].left[SliderImpl[id].t]
          cornerRadius 2
        rectangle "right":
          box 8, 4, size-12, 4
          fill SliderImpl[id].right[SliderImpl[id].t]
          cornerRadius 2
    of Vertical:
      box x, y, 12, size
      # keep hovered color while dragging
      Slider[id].hover = Slider[id].drag
      # change color on hover
      onHover: Slider[id].hover = true
      # enable dragging on click
      onClick: Slider[id].drag = true
      # track position and mouse button
      if Slider[id].drag:
        Slider[id].drag = buttonDown[MOUSE_LEFT]
        Slider[id].pos = (((mouse.pos.y - current.screenBox.y) / size).clamp(0, 1.0)-1).abs
      # switch for style
      case style
      of sliderA:
        rectangle "handle":
          box 0, size-((size-4)*Slider[id].pos)-4, 12, 4
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "right":
          box 4, 0, 4, size-((size-4)*Slider[id].pos)-4
          fill SliderImpl[id].right[SliderImpl[id].t]
        rectangle "left":
          box 4, 0, 4, size
          fill SliderImpl[id].left[SliderImpl[id].t]
      of sliderB:
        rectangle "handle":
          box 0, size-((size-12)*Slider[id].pos)-12, 12, 12
          cornerRadius 6
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "right":
          box 4, 4, 4, size-((size-4)*Slider[id].pos)-4
          fill SliderImpl[id].right[SliderImpl[id].t]
          cornerRadius 2
        rectangle "left":
          box 4, 8, 4, size-12
          fill SliderImpl[id].left[SliderImpl[id].t]
          cornerRadius 2

    # logic for color transitions
    # check for changed colors
    if SliderImpl[id].last.i != idleColors or SliderImpl[id].last.h != hoverColors:
      # we set the gradient in a slightly unexpected way to reduce complexity
      var l: Color
      var h: Color
      var r: Color
      for n in current.nodes:
        case n.id
        of "left": l = n.fill
        of "handle": h = n.fill
        of "right": r = n.fill
        else: discard
      SliderImpl[id] =
        (
          SliderImpl[id].left.len-1,
          linearGradient(idleColors.left.parseHtmlHex(), l, TransFrames),
          linearGradient(idleColors.handle.parseHtmlHex(), h, TransFrames),
          linearGradient(idleColors.right.parseHtmlHex(), r, TransFrames),
          (idleColors, hoverColors), true
        )
    if SliderImpl[id].changed and SliderImpl[id].t == 0:
      SliderImpl[id] =
        (
          0,
          linearGradient(idleColors.left.parseHtmlHex(), hoverColors.left.parseHtmlHex(), TransFrames),
          linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), TransFrames),
          linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), TransFrames),
          (idleColors, hoverColors), false
        )
    # do the actual transitioning
    if Slider[id].hover:
      if SliderImpl[id].t < SliderImpl[id].left.len-1: SliderImpl[id].t += 1
    else:
      if SliderImpl[id].t > 0: SliderImpl[id].t -= 1

proc createButton*(
  id: string,
  x, y, w, h: float,
  label: string,
  typeface: tuple[name: string, size, weight: float],
  idleColors: tuple[fill, text: string] = ("#70bdcf", "#FFFFFF"),
  hoverColors: tuple[fill, text: string] = ("#9fe7f8", "#FFFFFF"),
  style: ButtonStyle = buttonA,
  action: proc() = nil
) =
  # init in table
  discard Button.hasKeyOrPut(id, (hover: false))
  discard ButtonImpl.hasKeyOrPut(id,
    (
      0,
      linearGradient(idleColors.fill.parseHtmlHex(), hoverColors.fill.parseHtmlHex(), TransFrames),
      linearGradient(idleColors.text.parseHtmlHex(), hoverColors.text.parseHtmlHex(), TransFrames),
      (idleColors, hoverColors), false
    )
  )

  group "button":
    box x, y, w, h
    if mouseOverlapLogic(): Button[id].hover = true
    else: Button[id].hover = false
    fill ButtonImpl[id].fill[ButtonImpl[id].t]
    case style
    of buttonA: discard
    of buttonB: cornerRadius 6
    of buttonC: cornerRadius round(h/2-0.1)
    onClick: action()
    text "text":
      box 0, 0, w, h
      fill ButtonImpl[id].text[ButtonImpl[id].t]
      strokeWeight 1
      font typeface.name, typeface.size, typeface.weight, 20, hCenter, vCenter
      characters label

      # logic for color transitions
      # check for changed colors
      if ButtonImpl[id].last.i != idleColors or ButtonImpl[id].last.h != hoverColors:
          ButtonImpl[id] =
            (
              ButtonImpl[id].fill.len-1,
              linearGradient(idleColors.fill.parseHtmlHex(), parent.fill, TransFrames),
              linearGradient(idleColors.text.parseHtmlHex(), current.fill, TransFrames),
              (idleColors, hoverColors), true
            )
      if ButtonImpl[id].changed and ButtonImpl[id].t == 0:
        ButtonImpl[id] =
          (
            0,
            linearGradient(idleColors.fill.parseHtmlHex(), hoverColors.fill.parseHtmlHex(), TransFrames),
            linearGradient(idleColors.text.parseHtmlHex(), hoverColors.text.parseHtmlHex(), TransFrames),
            (idleColors, hoverColors), false
          )
      # do the actual transitioning
      if Button[id].hover:
        if ButtonImpl[id].t < ButtonImpl[id].fill.len-1: ButtonImpl[id].t += 1
      else:
        if ButtonImpl[id].t > 0: ButtonImpl[id].t -= 1