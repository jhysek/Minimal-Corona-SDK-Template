return {
  fitScaleFactor = function(displayObject, fitWidth, fitHeight, enlarge)
    local scaleFactor = fitHeight / displayObject.height
    local newWidth = displayObject.width * scaleFactor
    if newWidth > fitWidth then
      scaleFactor = fitWidth / displayObject.width
    end
    if not enlarge and scaleFactor > 1 then
      return 1
    end
    return scaleFactor
  end,

  coverScaleFactor = function(displayObject, fitWidth, fitHeight, enlarge)
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


}
