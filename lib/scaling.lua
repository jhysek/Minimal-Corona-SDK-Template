--------------------------------------------------------------------------------
-- par funkci pro usnadneni skalovani display objectu tak,
-- aby se vesly do urcitych rozmeru
--------------------------------------------------------------------------------

local function fitScaleFactor(displayObject, fitWidth, fitHeight, enlarge)
  local scaleFactor = fitHeight / displayObject.contentHeight
  local newWidth = displayObject.contentWidth * scaleFactor
  if newWidth > fitWidth then
    scaleFactor = fitWidth / displayObject.contentWidth
  end
  if not enlarge and scaleFactor > 1 then
    return 1
  end
  return scaleFactor
end

local function coverScaleFactor(displayObject, fitWidth, fitHeight, enlarge)
  local scaleFactor = fitHeight / displayObject.height
  local newWidth = displayObject.width * scaleFactor
  if newWidth < fitWidth then
    scaleFactor = fitWidth / displayObject.width
  end
  if not enlarge and scaleFactor > 1 then
    return 1
  end
  return scaleFactor
end


return {
  fitScaleFactor   = fitScaleFactor,
  coverScaleFactor = coverScaleFactor,

  scaleToFit = function(displayObject, fitWidth, fitHeight, enlarge)
    if displayObject then
      local factor = fitScaleFactor(displayObject, fitWidth, fitHeight, enlarge)
      displayObject:scale(factor, factor)
    end
  end,

  scaleToCover = function(displayObject, fitWidth, fitHeight, enlarge)
    if displayObject then
      local factor = coverScaleFactor(displayObject, fitWidth, fitHeight, enlarge)
      displayObject:scale(factor, factor)
    end
  end,
}
