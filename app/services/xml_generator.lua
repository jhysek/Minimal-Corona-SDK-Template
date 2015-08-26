return {
  generate = function(code, calculator, info)
    code = code or ""
    result = ""

    for in_code, value in pairs(calculator.inputs) do
      result = result .. "<input code='" .. code .. "." .. in_code .. "'>" .. value .. "</input>"
    end

    for in_code, value in pairs(info) do
      result = result .. "<input code='" .. in_code .. "'>" .. value .. "</input>"
    end

    result = result .. "<output code='positive_points'>" .. calculator.zaporne .. "</output>"
    result = result .. "<output code='negative_points'>" .. calculator.kladne .. "</output>"
    result = result .. "<output code='total_points'>" .. calculator.soucet .. "</output>"
    result = result .. "<output code='medal'>" .. calculator.medal .. "</output>"

    return "<?xml version='1.0' encoding='UTF-8'?><calculation code='" .. code .. "'>" .. result .. "</calculation>"
  end
}
