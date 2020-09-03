## Lean sacrifices animations in exchange for using a bit less memory and performance.
## The docs for Mean and Lean are practically identical.
## 
## [Documentation for Lite](lite.html)
## 
## [Main Page](../index.html)

import fidget

import tables
export `[]`

from math import round

import types
export types

const EmptyStringSeq: seq[string] = @[]

var Slider* = initTable[string, tuple[drag, hover: bool, val: SliderRange]]()
  ## Public data for sliders.
  ## 
  ## The only data you probably care about is `val`, which ranges from `0.0` to
  ## `1.0`. Just do some math to get the range you want.

var Button* = initTable[string, tuple[hover: bool]]()
  ## Public data for buttons.
  ## 
  ## You probably won't need this.

var Toggle* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for toggle switches.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or
  ## `false`.

var Checkbox* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for checkboxes.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or 
  ## `false`.

var Radio* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for radio buttons.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or 
  ## `false`.
var RadioGroups = initTable[string, seq[string]]()

proc createSlider*(
  id: string,
  x, y, size: float,
  initVal: SliderRange = 0.0,
  idleColors: tuple[left, handle, right: string] = ("#70bdcf", "#70bdcf", "#e5f7fe"),
  hoverColors: tuple[left, handle, right: string] = ("#9fe7f8", "#9fe7f8", "#e5f7fe"),
  style: SliderStyle = sliderA, orientation: Orientation = Horizontal
) =
  ## Creates a slider.
  ## 
  ## `id` - The ID of the slider, used to access its data. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the slider will be placed at.
  ## 
  ## `size` - Either the width or height of the slider, depending on `orientation`.
  ## 
  ## `initVal` - How far along the slider the handle will start at, from `0.0` to `1.0`.
  ## 
  ## `idleColors`, `hoverColors` - The colors of each part of the slider. When
  ## `orientation` is `Vertical`, `left` and `right` become the bottom and top
  ## respectively.
  ## 
  ## `style` - The style of the slider, either `sliderA` or `sliderB`.
  ## 
  ## `orientation` - The direction of the slider.

  # init in tables
  discard Slider.hasKeyOrPut(id, (false, false, initVal))

  group "slider":
    case orientation
    of Horizontal:
      box x, y, size, 18
      # keep hovered color while dragging
      Slider[id].hover = Slider[id].drag
      # change color on hover
      onHover: Slider[id].hover = true
      # enable dragging on click
      onClick: Slider[id].drag = true
      # track valition and mouse button
      if Slider[id].drag:
        Slider[id].drag = buttonDown[MOUSE_LEFT]
        Slider[id].val = ((mouse.pos.x - current.screenBox.x) / size).clamp(0, 1.0)
      # switch for style
      case style
      of sliderA:
        rectangle "handle":
          box Slider[id].val*(size-6), 0, 6, 18
          fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
        rectangle "left":
          box 0, 6, Slider[id].val*size, 6
          fill if Slider[id].hover: hoverColors.left else: idleColors.left
        rectangle "right":
          box 0, 6, size, 6
          fill if Slider[id].hover: hoverColors.right else: idleColors.right
      of sliderB:
        rectangle "handle":
          box Slider[id].val*(size-18), 0, 18, 18
          cornerRadius 9
          fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
        rectangle "left":
          box 6, 6, Slider[id].val*(size-12), 6
          fill if Slider[id].hover: hoverColors.left else: idleColors.left
          cornerRadius 3
        rectangle "right":
          box 12, 6, size-18, 6
          fill if Slider[id].hover: hoverColors.right else: idleColors.right
          cornerRadius 3
    of Vertical:
      box x, y, 18, size
      # keep hovered color while dragging
      Slider[id].hover = Slider[id].drag
      # change color on hover
      onHover: Slider[id].hover = true
      # enable dragging on click
      onClick: Slider[id].drag = true
      # track valition and mouse button
      if Slider[id].drag:
        Slider[id].drag = buttonDown[MOUSE_LEFT]
        Slider[id].val = (((mouse.pos.y - current.screenBox.y) / size).clamp(0, 1.0)-1).abs
      # switch for style
      case style
      of sliderA:
        rectangle "handle":
          box 0, size-((size-6)*Slider[id].val)-6, 18, 6
          fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
        rectangle "right":
          box 6, 0, 6, size-((size-6)*Slider[id].val)-6
          fill if Slider[id].hover: hoverColors.right else: idleColors.right
        rectangle "left":
          box 6, 0, 6, size
          fill if Slider[id].hover: hoverColors.left else: idleColors.left
      of sliderB:
        rectangle "handle":
          box 0, size-((size-18)*Slider[id].val)-18, 18, 18
          cornerRadius 9
          fill if Slider[id].hover: hoverColors.handle else: idleColors.handle
        rectangle "right":
          box 6, 6, 6, size-((size-6)*Slider[id].val)-6
          fill if Slider[id].hover: hoverColors.right else: idleColors.right
          cornerRadius 3
        rectangle "left":
          box 6, 12, 6, size-18
          fill if Slider[id].hover: hoverColors.left else: idleColors.left
          cornerRadius 3

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
  ## Creates a button.
  ## 
  ## `id` - The ID of the button, used to access its data. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the button will be placed at.
  ## 
  ## `w`, `h` - The width and height of the button respectively.
  ## 
  ## `label` - The text to display on the button.
  ## 
  ## `typeface` - Information about the font to use.
  ## 
  ## `idleColors`, `hoverColors` - The colors of each part of the button.
  ## 
  ## `style` - The style of the button, `buttonA`, buttonB`, or `buttonC`.
  ## 
  ## `action` - A procedure to be executed when the button is clicked.

  # init in table
  discard Button.hasKeyOrPut(id, (hover: false))

  group "button":
    box x, y, w, h
    if mouseOverlapLogic(): Button[id].hover = true
    else: Button[id].hover = false
    fill if Button[id].hover: hoverColors.fill else: idleColors.fill
    case style
    of buttonA: discard
    of buttonB: cornerRadius 9
    of buttonC: cornerRadius round(h/2-0.1)
    onClick:
      if action != nil: action()
    text "text":
      box 0, 0, w, h
      fill if Button[id].hover: hoverColors.text else: idleColors.text
      strokeWeight 1
      font typeface.name, typeface.size, typeface.weight, 20, hCenter, vCenter
      characters label

proc createToggle*(
  id: string,
  x, y: float,
  initVal = false,
  idleColors: tuple[handle, right: string] = ("#70bdcf", "#e5f7fe"),
  hoverColors: tuple[handle, right: string] = ("#9fe7f8", "#e5f7fe"),
  style: ToggleStyle = toggleA, orientation: Orientation = Horizontal
) =
  ## Creates a toggle switch.
  ## 
  ## `id` - The ID of the switch, used to access its data. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the switch will be placed at.
  ## 
  ## `initVal` - The state for the switch to start at, either `true` or `false`.
  ## 
  ## `idleColors`, `hoverColors` - The colors of each part of the switch. When
  ## `orientation` is `Vertical`, `handle` and `right` become the bottom and top
  ## respectively.
  ## 
  ## `style` - The style of the switch, `toggleA`, `toggleB`, or `toggleC`.
  ## 
  ## `orientation` - The direction of the slider.

  # init in tables
  discard Toggle.hasKeyOrPut(id, (initVal, false))

  group "toggle":
    if mouseOverlapLogic(): Toggle[id].hover = true
    else: Toggle[id].hover = false
    onClick: Toggle[id].val = not Toggle[id].val
    case orientation
    of Horizontal:
      box x, y, 36, 18
      rectangle "handle":
        box 0, 0, if Toggle[id].val: 36 else: 18, 18
        fill if Toggle[id].hover: hoverColors.handle else: idleColors.handle
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
      rectangle "right":
        box 0, 0, 36, 18
        fill if Toggle[id].hover: hoverColors.right else: idleColors.right
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
    of Vertical:
      box x, y, 18, 36
      rectangle "handle":
        box 0, if Toggle[id].val: 0 else: 18, 18, if Toggle[id].val: 36 else: 18
        fill if Toggle[id].hover: hoverColors.handle else: idleColors.handle
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
      rectangle "right":
        box 0, 0, 18, 36
        fill if Toggle[id].hover: hoverColors.right else: idleColors.right
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9

proc createCheckbox*(
  id: string,
  x, y: float,
  initVal = false,
  idleColors: tuple[off, on: string] = ("#e5f7fe", "#70bdcf"),
  hoverColors: tuple[off, on: string] = ("#e5f7fe", "#9fe7f8"),
  style: CheckboxStyle = checkboxA
) =
  ## Creates a checkbox.
  ## 
  ## `id` - The ID of the checkbox, used to access its data. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the checkbox will be placed at.
  ## 
  ## `initVal` - The state for the checkbox to start at, either `true` or `false`.
  ## 
  ## `idleColors`, `hoverColors` - The colors of each part of the checkbox.
  ## 
  ## `style` - The style of the checkbox, either `checkboxA` or `checkboxB`.

  # init in tables
  discard Checkbox.hasKeyOrPut(id, (initVal, false))
  group "checkbox":
    box x, y, 18, 18
    if mouseOverlapLogic(): Checkbox[id].hover = true
    else: Checkbox[id].hover = false
    onClick: Checkbox[id].val = not Checkbox[id].val
    if Checkbox[id].val:
      rectangle "on":
        box 0, 0, 18, 18
        fill if Checkbox[id].hover: hoverColors.on else: idleColors.on
        case style
        of checkboxA: cornerRadius 0
        of checkboxB: cornerRadius 5
    rectangle "off":
      box 0, 0, 18, 18
      fill if Checkbox[id].hover: hoverColors.off else: idleColors.off
      case style
      of checkboxA: cornerRadius 0
      of checkboxB: cornerRadius 5

proc createRadio*(
  id, radioGroup: string,
  x, y: float,
  initVal = false,
  idleColors: tuple[off, on: string] = ("#e5f7fe", "#70bdcf"),
  hoverColors: tuple[off, on: string] = ("#e5f7fe", "#9fe7f8")
) =
  ## Creates a radio button.
  ## 
  ## `id` - The ID of the radio, used to access its data. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the radio will be placed at.
  ## 
  ## `initVal` - The state for the radio to start at, either `true` or `false`.
  ## 
  ## `idleColors`, `hoverColors` - The colors of each part of the radio.

  # init in tables
  discard Radio.hasKeyOrPut(id, (initVal, false))
  discard RadioGroups.hasKeyOrPut(radioGroup, EmptyStringSeq)
  if id notin RadioGroups[radioGroup]:
    RadioGroups[radioGroup].add(id)
  group "Radio":
    box x, y, 18, 18
    if mouseOverlapLogic(): Radio[id].hover = true
    else: Radio[id].hover = false

    for x in RadioGroups[radioGroup]:
      if x != id and Radio[x].val == true:
        Radio[id].val = false
        break
    onClick: Radio[id].val = not Radio[id].val

    if Radio[id].val:
      rectangle "on":
        box 0, 0, 18, 18
        fill if Radio[id].hover: hoverColors.on else: idleColors.on
        cornerRadius 9
    rectangle "off":
      box 0, 0, 18, 18
      fill if Radio[id].hover: hoverColors.off else: idleColors.off
      cornerRadius 9

proc createProgress*(
  id: string,
  x, y, size: float,
  val: SliderRange,
  colors: tuple[left, right: string] = ("#70bdcf", "#e5f7fe"),
  style: ProgressStyle = progressA, orientation: Orientation = Horizontal
) =
  ## Creates a progress bar.
  ## 
  ## `id` - The ID of the progress bar. Must be unique.
  ## 
  ## `x`, `y` - The X and Y coordinates the progress bar will be placed at.
  ## 
  ## `size` - Either the width or height of the progress bar, depending on `orientation`.
  ## 
  ## `val` - How far along the progress bar should be, from `0.0` to `1.0`.
  ## 
  ## `colors` - The colors of each part of the progress bar.
  ## 
  ## `style` - The style of the checkbox, `progressA`, `progressB`, or `progressC`.
  ## 
  ## `orientation` - The direction of the progress bar.
  group "progress":
    case orientation
    of Horizontal:
      box x, y, size, 18
      rectangle "left":
        box 0, 0, val*size, 18
        fill colors.left
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
      rectangle "right":
        box 0, 0, size, 18
        fill colors.right
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
    of Vertical:
      box x, y, 18, size
      rectangle "left":
        box 0, size-(val*size), 18, val*size
        fill colors.left
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
      rectangle "right":
        box 0, 0, 18, size
        fill colors.right
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9