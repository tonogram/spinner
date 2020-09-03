## Spinner is a companion library for Fidget that provides a handful of useful
## components for speeding up app development.
## 
## ```nim
## import fidget, spinner/lean
## 
## proc drawMain() =
##   createProgress("load_amnt", 0, 0, 200, 0.5, orientation=Vertical)
##   createSlider("some_value", 36, 0, 100, 0.5)
##   createButton("perform_action", 36, 36, 100, 36, "Example Button", ("Roboto", 12.0, 400.0))
##   createToggle("change_setting", 36, 90)
##   createCheckbox("choose_something", 90, 90)
##   createRadio("option1", "group1", 36, 126)
##   createRadio("option2", "group1", 72, 126)
## 
## startFidget(drawmain)
## ```
## 
## -----
## 
## Spinner comes in three flavors: Mean, Lean, and Lite. Mean is the aesthetics-first
## version of Spinner, implementing some animations to make your app look nice
## at a minor memory and performance cost. Lean's components are identical to
## Mean's, but skip on the animations. Lite is even more lightweight than Lean,
## but is very limited in customization.
## 
## Lean and Mean can seamlessly be swapped out with one another; just change the
## import path. Lite cannot be swapped without changes.
## 
## ```nim
## import fidget # You'll still need Fidget too.
## 
## # Pick one:
## import spinner/mean
## import spinner/lean # Mean code == Lean code, just change the import.
## import spinner/lite # Requires changes.
## 
## import spinner # Defaults to Mean.
## ```
## 
## If you start Fidget with [mainLoopMode](https://github.com/treeform/fidget/blob/master/src/fidget/openglbackend.nim#L371)
## at its default, only use Lean or Lite as animations will not work properly otherwise.
## 
## -----
## 
## Spinner's components also serve as a great reference for building your own.
## Please save yourself a headache and look at the Lean or Lite versions of the
## code, as they are much easier to understand.
## 
## -----
## 
## To access data from any component, call it from the appropriate table.
## Slider example:
## ```nim
## echo Slider["some ID"].val
## ```
## Different components hold different data, but generally `.val` will give you
## what you want. Other than calling data, just about everything else is better
## placed in the submodule's respective documentation.
## 
## -----
## 
## [Documentation for Mean/Lean's Procedures](meanlean.html)
## 
## [Documentation for Lite's Procedures](lite.html)
## 
## [Documentation for Types](types.html)

import spinner/mean
export mean