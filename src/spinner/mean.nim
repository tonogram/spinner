## Mean uses up a bit of extra performance and memory in exchange for some animations.
## The docs for Mean and Lean are practically identical.
## 
## [Documentation for Lite](lite.html)
## 
## [Main Page](../index.html)

import fidget, gradient

import tables
export `[]`

from math import round

import types
export types

const EmptyStringSeq: seq[string] = @[]

var AnimationLength* = (60/10).int
  ## How long the animations should last, in frames. Exclusive to Mean.
  ## 
  ## In the future, should get the display's refresh rate for the calculation.

var Slider* = initTable[string, tuple[drag, hover: bool, val: SliderRange]]()
  ## Public data for sliders.
  ## 
  ## The only data you probably care about is `val`, which ranges from `0.0` to
  ## `1.0`. Just do some math to get the range you want.
var SliderImpl = initTable[string, tuple[t: int, left, handle, right: seq[Color], last: tuple[i, h: tuple[left, handle, right: string]], changed: bool]]()

var Button* = initTable[string, tuple[hover: bool]]()
  ## Public data for buttons.
  ## 
  ## You probably won't need this.
var ButtonImpl = initTable[string, tuple[t: int, fill, text: seq[Color], last: tuple[i, h: tuple[fill, text: string]], changed: bool]]()

var Toggle* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for toggle switches.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or
  ## `false`.
var ToggleImpl = initTable[string, tuple[t: int, pos: float, handle, right: seq[Color], last: tuple[i, h: tuple[handle, right: string]], changed: bool]]()

var Checkbox* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for checkboxes.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or 
  ## `false`.
var CheckboxImpl = initTable[string, tuple[t: int, pos: float, off, on: seq[Color], last: tuple[i, h: tuple[off, on: string]], changed: bool]]()

var Radio* = initTable[string, tuple[val, hover: bool]]()
  ## Public data for radio buttons.
  ## 
  ## The only data you probably care about is `val`, which is either `true` or 
  ## `false`.
var RadioImpl = initTable[string, tuple[t: int, pos: float, off, on: seq[Color], last: tuple[i, h: tuple[off, on: string]], changed: bool]]()
var RadioGroups = initTable[string, seq[string]]()

var ProgressImpl = initTable[string, tuple[t: int, left, right: seq[Color], last: tuple[left, right: string], changed: bool]]()

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
  discard SliderImpl.hasKeyOrPut(id,
    (
      0,
      linearGradient(idleColors.left.parseHtmlHex(), hoverColors.left.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), AnimationLength),
      (idleColors, hoverColors), false
    )
  )

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
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "left":
          box 0, 6, Slider[id].val*size, 6
          fill SliderImpl[id].left[SliderImpl[id].t]
        rectangle "right":
          box 0, 6, size, 6
          fill SliderImpl[id].right[SliderImpl[id].t]
      of sliderB:
        rectangle "handle":
          box Slider[id].val*(size-18), 0, 18, 18
          cornerRadius 9
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "left":
          box 6, 6, Slider[id].val*(size-12), 6
          fill SliderImpl[id].left[SliderImpl[id].t]
          cornerRadius 3
        rectangle "right":
          box 12, 6, size-18, 6
          fill SliderImpl[id].right[SliderImpl[id].t]
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
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "right":
          box 6, 0, 6, size-((size-6)*Slider[id].val)-6
          fill SliderImpl[id].right[SliderImpl[id].t]
        rectangle "left":
          box 6, 0, 6, size
          fill SliderImpl[id].left[SliderImpl[id].t]
      of sliderB:
        rectangle "handle":
          box 0, size-((size-18)*Slider[id].val)-18, 18, 18
          cornerRadius 9
          fill SliderImpl[id].handle[SliderImpl[id].t]
        rectangle "right":
          box 6, 6, 6, size-((size-6)*Slider[id].val)-6
          fill SliderImpl[id].right[SliderImpl[id].t]
          cornerRadius 3
        rectangle "left":
          box 6, 12, 6, size-18
          fill SliderImpl[id].left[SliderImpl[id].t]
          cornerRadius 3

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
          linearGradient(idleColors.left.parseHtmlHex(), l, AnimationLength),
          linearGradient(idleColors.handle.parseHtmlHex(), h, AnimationLength),
          linearGradient(idleColors.right.parseHtmlHex(), r, AnimationLength),
          (idleColors, hoverColors), true
        )
    if SliderImpl[id].changed and SliderImpl[id].t == 0:
      SliderImpl[id] =
        (
          0,
          linearGradient(idleColors.left.parseHtmlHex(), hoverColors.left.parseHtmlHex(), AnimationLength),
          linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), AnimationLength),
          linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), AnimationLength),
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
  discard ButtonImpl.hasKeyOrPut(id,
    (
      0,
      linearGradient(idleColors.fill.parseHtmlHex(), hoverColors.fill.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.text.parseHtmlHex(), hoverColors.text.parseHtmlHex(), AnimationLength),
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
    of buttonB: cornerRadius 9
    of buttonC: cornerRadius round(h/2-0.1)
    onClick:
      if action != nil: action()
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
              linearGradient(idleColors.fill.parseHtmlHex(), parent.fill, AnimationLength),
              linearGradient(idleColors.text.parseHtmlHex(), current.fill, AnimationLength),
              (idleColors, hoverColors), true
            )
      if ButtonImpl[id].changed and ButtonImpl[id].t == 0:
        ButtonImpl[id] =
          (
            0,
            linearGradient(idleColors.fill.parseHtmlHex(), hoverColors.fill.parseHtmlHex(), AnimationLength),
            linearGradient(idleColors.text.parseHtmlHex(), hoverColors.text.parseHtmlHex(), AnimationLength),
            (idleColors, hoverColors), false
          )
      # do the actual transitioning
      if Button[id].hover:
        if ButtonImpl[id].t < ButtonImpl[id].fill.len-1: ButtonImpl[id].t += 1
      else:
        if ButtonImpl[id].t > 0: ButtonImpl[id].t -= 1

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
  ## `orientation` - The direction of the switch.

  # init in tables
  discard Toggle.hasKeyOrPut(id, (initVal, false))
  discard ToggleImpl.hasKeyOrPut(id,
    (
      0, initVal.float*18,
      linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), AnimationLength),
      (idleColors, hoverColors), false
    )
  )
  group "toggle":
    if mouseOverlapLogic(): Toggle[id].hover = true
    else: Toggle[id].hover = false
    onClick: Toggle[id].val = not Toggle[id].val
    case orientation
    of Horizontal:
      box x, y, 36, 18
      rectangle "handle":
        box 0, 0, 18+ToggleImpl[id].pos, 18
        fill ToggleImpl[id].handle[ToggleImpl[id].t]
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
      rectangle "right":
        box 0, 0, 36, 18
        fill ToggleImpl[id].right[ToggleImpl[id].t]
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
    of Vertical:
      box x, y, 18, 36
      rectangle "handle":
        box 0, 18-ToggleImpl[id].pos, 18, 18+ToggleImpl[id].pos
        fill ToggleImpl[id].handle[ToggleImpl[id].t]
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9
      rectangle "right":
        box 0, 0, 18, 36
        fill ToggleImpl[id].right[ToggleImpl[id].t]
        case style
        of toggleA: discard
        of toggleB: cornerRadius 5
        of toggleC: cornerRadius 9

    # logic for color transitions
    # check for changed colors
    if ToggleImpl[id].last.i != idleColors or ToggleImpl[id].last.h != hoverColors:
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
      ToggleImpl[id] =
        (
          ToggleImpl[id].handle.len-1, ToggleImpl[id].pos,
          linearGradient(idleColors.handle.parseHtmlHex(), h, AnimationLength),
          linearGradient(idleColors.right.parseHtmlHex(), r, AnimationLength),
          (idleColors, hoverColors), true
        )
    if ToggleImpl[id].changed and ToggleImpl[id].t == 0:
      ToggleImpl[id] =
        (
          0, ToggleImpl[id].pos,
          linearGradient(idleColors.handle.parseHtmlHex(), hoverColors.handle.parseHtmlHex(), AnimationLength),
          linearGradient(idleColors.right.parseHtmlHex(), hoverColors.right.parseHtmlHex(), AnimationLength),
          (idleColors, hoverColors), false
        )
    # do the actual transitioning
    if Toggle[id].hover:
      if ToggleImpl[id].t < ToggleImpl[id].handle.len-1: ToggleImpl[id].t += 1
    else:
      if ToggleImpl[id].t > 0: ToggleImpl[id].t -= 1
    
    if Toggle[id].val:
      if ToggleImpl[id].pos < 18.0: ToggleImpl[id].pos = (ToggleImpl[id].pos + (18 / (ToggleImpl[id].handle.len-1))).clamp(0.0, 18.0)
    else:
      if ToggleImpl[id].pos > 0.0: ToggleImpl[id].pos = (ToggleImpl[id].pos - (18 / (ToggleImpl[id].handle.len-1))).clamp(0.0, 18.0)

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
  discard CheckboxImpl.hasKeyOrPut(id,
    (
      0, initVal.float*18,
      linearGradient(idleColors.off.parseHtmlHex(), hoverColors.off.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.on.parseHtmlHex(), hoverColors.on.parseHtmlHex(), AnimationLength),
      (idleColors, hoverColors), false
    )
  )
  group "checkbox":
    box x, y, 18, 18
    if mouseOverlapLogic(): Checkbox[id].hover = true
    else: Checkbox[id].hover = false
    onClick: Checkbox[id].val = not Checkbox[id].val
    rectangle "on":
      box 9-(CheckboxImpl[id].pos/2), 9-(CheckboxImpl[id].pos/2), CheckboxImpl[id].pos, CheckboxImpl[id].pos
      fill CheckboxImpl[id].on[CheckboxImpl[id].t]
      case style
      of checkboxA: cornerRadius 0
      of checkboxB: cornerRadius 5
    rectangle "off":
      box 0, 0, 18, 18
      fill CheckboxImpl[id].off[CheckboxImpl[id].t]
      case style
      of checkboxA: cornerRadius 0
      of checkboxB: cornerRadius 5
    # logic for color transitions
    # check for changed colors
    if CheckboxImpl[id].last.i != idleColors or CheckboxImpl[id].last.h != hoverColors:
      # we set the gradient in a slightly unexpected way to reduce complexity
      var off: Color
      var on: Color
      for n in current.nodes:
        case n.id
        of "on": on = n.fill
        of "off": off = n.fill
        else: discard
      CheckboxImpl[id] =
        (
          CheckboxImpl[id].off.len-1, CheckboxImpl[id].pos,
          linearGradient(idleColors.off.parseHtmlHex(), off, AnimationLength),
          linearGradient(idleColors.on.parseHtmlHex(), on, AnimationLength),
          (idleColors, hoverColors), true
        )
    if CheckboxImpl[id].changed and CheckboxImpl[id].t == 0:
      CheckboxImpl[id] =
        (
          0, CheckboxImpl[id].pos,
          linearGradient(idleColors.off.parseHtmlHex(), hoverColors.off.parseHtmlHex(), AnimationLength),
          linearGradient(idleColors.on.parseHtmlHex(), hoverColors.on.parseHtmlHex(), AnimationLength),
          (idleColors, hoverColors), false
        )
    # do the actual transitioning
    if Checkbox[id].hover:
      if CheckboxImpl[id].t < CheckboxImpl[id].off.len-1: CheckboxImpl[id].t += 1
    else:
      if CheckboxImpl[id].t > 0: CheckboxImpl[id].t -= 1
    
    if Checkbox[id].val:
      if CheckboxImpl[id].pos < 18.0: CheckboxImpl[id].pos = (CheckboxImpl[id].pos + (18 / (CheckboxImpl[id].off.len-1))).clamp(0.0, 18.0)
    else:
      if CheckboxImpl[id].pos > 0.0: CheckboxImpl[id].pos = (CheckboxImpl[id].pos - (18 / (CheckboxImpl[id].off.len-1))).clamp(0.0, 18.0)

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
  discard RadioImpl.hasKeyOrPut(id,
    (
      0, initVal.float*18,
      linearGradient(idleColors.off.parseHtmlHex(), hoverColors.off.parseHtmlHex(), AnimationLength),
      linearGradient(idleColors.on.parseHtmlHex(), hoverColors.on.parseHtmlHex(), AnimationLength),
      (idleColors, hoverColors), false
    )
  )
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

    rectangle "on":
      box 9-(RadioImpl[id].pos/2), 9-(RadioImpl[id].pos/2), RadioImpl[id].pos, RadioImpl[id].pos
      fill RadioImpl[id].on[RadioImpl[id].t]
      cornerRadius 9
    rectangle "off":
      box 0, 0, 18, 18
      fill RadioImpl[id].off[RadioImpl[id].t]
      cornerRadius 9
    # logic for color transitions
    # check for changed colors
    if RadioImpl[id].last.i != idleColors or RadioImpl[id].last.h != hoverColors:
      # we set the gradient in a slightly unexpected way to reduce complexity
      var off: Color
      var on: Color
      for n in current.nodes:
        case n.id
        of "on": on = n.fill
        of "off": off = n.fill
        else: discard
      RadioImpl[id] =
        (
          RadioImpl[id].off.len-1, RadioImpl[id].pos,
          linearGradient(idleColors.off.parseHtmlHex(), off, AnimationLength),
          linearGradient(idleColors.on.parseHtmlHex(), on, AnimationLength),
          (idleColors, hoverColors), true
        )
    if RadioImpl[id].changed and RadioImpl[id].t == 0:
      RadioImpl[id] =
        (
          0, RadioImpl[id].pos,
          linearGradient(idleColors.off.parseHtmlHex(), hoverColors.off.parseHtmlHex(), AnimationLength),
          linearGradient(idleColors.on.parseHtmlHex(), hoverColors.on.parseHtmlHex(), AnimationLength),
          (idleColors, hoverColors), false
        )
    # do the actual transitioning
    if Radio[id].hover:
      if RadioImpl[id].t < RadioImpl[id].off.len-1: RadioImpl[id].t += 1
    else:
      if RadioImpl[id].t > 0: RadioImpl[id].t -= 1
    
    if Radio[id].val:
      if RadioImpl[id].pos < 18.0: RadioImpl[id].pos = (RadioImpl[id].pos + (18 / (RadioImpl[id].off.len-1))).clamp(0.0, 18.0)
    else:
      if RadioImpl[id].pos > 0.0: RadioImpl[id].pos = (RadioImpl[id].pos - (18 / (RadioImpl[id].off.len-1))).clamp(0.0, 18.0)

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

  discard ProgressImpl.hasKeyOrPut(id,
    (
      0,
      linearGradient(colors.left.parseHtmlHex(), colors.left.parseHtmlHex(), AnimationLength),
      linearGradient(colors.right.parseHtmlHex(), colors.right.parseHtmlHex(), AnimationLength),
      colors, false
    )
  )

  group "progress":
    case orientation
    of Horizontal:
      box x, y, size, 18
      # switch for style
      rectangle "left":
        box 0, 0, val*size, 18
        fill ProgressImpl[id].left[ProgressImpl[id].t]
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
      rectangle "right":
        box 0, 0, size, 18
        fill ProgressImpl[id].right[ProgressImpl[id].t]
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
    of Vertical:
      box x, y, 18, size
      rectangle "left":
        box 0, size-(val*size), 18, val*size
        fill ProgressImpl[id].left[ProgressImpl[id].t]
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9
      rectangle "right":
        box 0, 0, 18, size
        fill ProgressImpl[id].right[ProgressImpl[id].t]
        case style
        of progressA: discard
        of progressB: cornerRadius 5
        of progressC: cornerRadius 9

    # logic for color transitions
    # check for changed colors
    if ProgressImpl[id].last != colors:
      # we set the gradient in a slightly unexpected way to reduce complexity
      var l: Color
      var r: Color
      for n in current.nodes:
        case n.id
        of "left": l = n.fill
        of "right": r = n.fill
        else: discard
      ProgressImpl[id] =
        (
          ProgressImpl[id].left.len-1,
          linearGradient(colors.left.parseHtmlHex(), l, AnimationLength),
          linearGradient(colors.right.parseHtmlHex(), r, AnimationLength),
          colors, true
        )
    if ProgressImpl[id].changed and ProgressImpl[id].t == 0:
      ProgressImpl[id] =
        (
          0,
          linearGradient(colors.left.parseHtmlHex(), colors.left.parseHtmlHex(), AnimationLength),
          linearGradient(colors.right.parseHtmlHex(), colors.right.parseHtmlHex(), AnimationLength),
          colors, false
        )

    if ProgressImpl[id].t > 0: ProgressImpl[id].t -= 1