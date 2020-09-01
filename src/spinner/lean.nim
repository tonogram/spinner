import fidget

import tables

import types
export types

var Slider* = initTable[string, tuple[drag, hover: bool, pos: float]]()
  ## Public data for sliders.

proc createSlider*(
  id: string,
  x, y, width: float,
  initPos: SliderRange = 0.0,
  idleColors: tuple[left, handle, right: string] = ("#70bdcf", "#70bdcf", "#e5f7fe"),
  hoverColors: tuple[left, handle, right: string] = ("#9fe7f8", "#9fe7f8", "#e5f7fe"),
  style: SliderStyle = A
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
  group "slider":
    box x, y, width, 12
    # keep hovered color while dragging
    Slider[id].hover = Slider[id].drag
    # change color on hover
    onHover: Slider[id].hover = true
    # enable dragging on click
    onClick: Slider[id].drag = true
    # track position and mouse button
    if Slider[id].drag:
      Slider[id].drag = buttonDown[MOUSE_LEFT]
      Slider[id].pos = ((mouse.pos.x - current.screenBox.x) / width).clamp(0, 1.0)

    # switch for style
    case style
    of A:
      rectangle "handle":
        box Slider[id].pos*(width-4), 0, 4, 12
        fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
      rectangle "left":
        box 0, 4, Slider[id].pos*width, 4
        fill if Slider[id].hover: hoverColors.left else: idleColors.left
      rectangle "right":
        box 0, 4, width, 4
        fill if Slider[id].hover: hoverColors.right else: idleColors.right
    of B:
      rectangle "handle":
        box Slider[id].pos*(width-12), 0, 12, 12
        cornerRadius 6
        fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
      rectangle "left":
        box 4, 4, Slider[id].pos*(width-8), 4
        fill if Slider[id].hover: hoverColors.left else: idleColors.left
        cornerRadius 2
      rectangle "right":
        box 8, 4, width-12, 4
        fill if Slider[id].hover: hoverColors.right else: idleColors.right
        cornerRadius 2