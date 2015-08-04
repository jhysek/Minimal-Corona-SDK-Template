Color = {}

function Color.convertHexToRGB(hexCode)
  assert(#hexCode == 7, "The hex value must be passed in the form of #XXXXXX");
  local hexCode = hexCode:gsub("#","")

  return {
    tonumber("0x"..hexCode:sub(1,2)) / 255,
    tonumber("0x"..hexCode:sub(3,4)) / 255,
    tonumber("0x"..hexCode:sub(5,6)) / 255
  }
end

function Color.setFillHexColor(object, hexColor, alpha)
  local color = Color.convertHexToRGB(hexColor)
  alpha = alpha or 1
  object:setFillColor(color[1], color[2], color[3], alpha)
end

function Color.setStrokeHexColor(object, hexColor, alpha)
  local color = Color.convertHexToRGB(hexColor)
  alpha = alpha or 1
  object:setStrokeColor(color[1], color[2], color[3], alpha)
end

function Color.setDefaultHexBackground(hexColor, alpha)
  local color = Color.convertHexToRGB(hexColor)
  alpha = alpha or 1
  display.setDefault('background',  color[1], color[2], color[3], alpha)
end

return Color
