storyboard = require("storyboard")

_W = display.contentWidth
_H = display.contentHeight
_AW = display.actualContentWidth
_AH = display.actualContentHeight
_T = display.screenOriginY
_B = _T + _AH
_L = display.screenOriginX
_R = _L + _AW

display.setStatusBar( display.HiddenStatusBar )
storyboard.gotoScene("app.menu")
