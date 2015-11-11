return {
  conditional_draw = function(parent, text, top)
    local height = 0

    if text and string.len(text) > 0 then
      height = 60

      local bg = display.newRect(parent, _AW / 2, top, _AW, height)
      bg.anchorY = 0
      bg:setFillColor(0.9, 0.9, 0.9)

      local text = display.newText({
        parent = parent,
        y = top + height / 2,
        x = _AW / 2,
        width = _AW - 20,
        text = text,
        font = native.systemFont,
        fontSize = 12,
        align = "center"
      })
      text:setFillColor(0,0,0)
    end

    return height
  end
}
