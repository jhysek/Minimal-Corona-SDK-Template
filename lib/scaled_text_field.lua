function native.newScaledTextField( centerX, centerY, width, desiredFontSize )
    -- Corona provides a resizeHeightToFitFont() feature on build #2520 or higher
    if ( tonumber( system.getInfo("build") ) >= 2014.2520 ) then
        local textField = native.newTextField(centerX, centerY, width, 30)
        local isFontSizeScaled = textField.isFontSizeScaled
        textField.isFontSizeScaled = true
        textField.size = desiredFontSize
        textField:resizeHeightToFitFont()
        textField.isFontSizeScaled = isFontSizeScaled
        return textField
    end
    local fontSize = desiredFontSize or 0

    -- Create a text object, measure its height, and then remove it
    local textToMeasure = display.newText( "X", 0, 0, native.systemFont, fontSize )
    local textHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    local scaledFontSize = fontSize / display.contentScaleY
    local textMargin = 20 * display.contentScaleY  -- convert 20 pixels to content coordinates

    -- Calculate the text input field's font size and vertical margin, per-platform
    local platformName = system.getInfo( "platformName" )
    if ( platformName == "iPhone OS" ) then
        local modelName = system.getInfo( "model" )
        if ( modelName == "iPad" ) or ( modelName == "iPad Simulator" ) then
            scaledFontSize = scaledFontSize / ( display.pixelWidth / 768 )
            textMargin = textMargin * ( display.pixelWidth / 768 )
        else
            scaledFontSize = scaledFontSize / ( display.pixelWidth / 320 )
            textMargin = textMargin * ( display.pixelWidth / 320 )
        end
    elseif ( platformName == "Android" ) then
        scaledFontSize = scaledFontSize / ( system.getInfo( "androidDisplayApproximateDpi" ) / 160 )
        textMargin = textMargin * ( system.getInfo( "androidDisplayApproximateDpi" ) / 160 )
    end

    -- Create a text field that fits the font size from above
    local textField = native.newTextField(
        centerX,
        centerY,
        width,
        textHeight + textMargin
    )
    textField.size = scaledFontSize
    return textField, scaledFontSize
end

