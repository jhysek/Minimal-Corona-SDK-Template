local Files = require "lib.copy_file"

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local function os_fields()
  local result = ""
  local os = system.getInfo("platformName")
  local smart_os = os == "Android" and 3 or 2
  local smart_type = system.getInfo("platformName") .. " " .. system.getInfo("platformVersion")

  result = result .. "<smart-os>" .. smart_os .. "</smart-os>"
  result = result .. "<smart-type>" .. smart_type .. "</smart-type>"
  result = result .. "<smart-id>" .. system.getInfo("deviceID") .. "</smart-id>"
  return result
end

local function get_xml_code(code)
  local form_definitions = loadTable("config/form_definitions.json", system.ResourceDirectory) or {sections = {}}
  for i = 1, #form_definitions.sections do
    local definition = form_definitions.sections[i]
    if definition.code == code then
      return definition.xml_code
    end
  end
end

local function encodePhoto(filename)
  if Files.doesFileExist(filename, system.DocumentsDirectory) then
    local path       = system.pathForFile(filename, system.DocumentsDirectory)
    local fh, reason = io.open( path, "r" )
    local content    = base64.encode(fh:read("*a"))

    io.close(fh)
    return "data:image/png;base64," .. content
  else
    return ""
  end
end

return {
  generate = function(code, calculator, info)
    code = code or ""
    result = "<type-evaluation>" .. get_xml_code(code) .. "</type-evaluation>"

    local date_parts = info.date:split(".")
    local date = string.format("%02d", date_parts[1]) ..
                 string.format("%02d", date_parts[2]) ..
                 string.format("%04d", date_parts[3])


    result = result .. "<age>"     .. info.age     .. "</age>"
    result = result .. "<dt-hunt>" .. date         .. "</dt-hunt>"
    result = result .. "<hunter>"  .. info.hunter  .. "</hunter>"
    result = result .. "<place>"   .. info.place   .. "</place>"
    result = result .. "<country>" .. info.country .. "</country>"
    result = result .. "<contact>" .. info.contact .. "</contact>"

    -- inputs ------------------------------------------------------------------
    evaluation_data = ""
    for in_code, value in pairs(calculator.inputs) do
      tag_name = code .. "-" .. in_code
      evaluation_data = evaluation_data  .. "<" .. tag_name .. ">" .. value .. "</".. tag_name ..">"
    end
    result = result .. "<evaluation-data>" .. evaluation_data .. "</evaluation-data>"

    -- outputs -----------------------------------------------------------------
    result = result .. "<evaluation-plus>"  .. calculator.kladne  .. "</evaluation-plus>"
    result = result .. "<evaluation-minus>" .. calculator.zaporne .. "</evaluation-minus>"
    result = result .. "<evaluation-sum>"   .. calculator.soucet  .. "</evaluation-sum>"
    result = result .. "<medal>"            .. calculator.medal   .. "</medal>"

    -- pictures ----------------------------------------------------------------
    result = result .. "<pict-1>" .. encodePhoto(values.photos[3]) .. "</pict-1>"
    result = result .. "<pict-2>" .. encodePhoto(values.photos[2]) .. "</pict-2>"
    result = result .. "<pict-3>" .. encodePhoto(values.photos[1]) .. "</pict-3>"

    -- OS info -----------------------------------------------------------------
    result = result .. os_fields()

    return "<xml-trophy>" .. result .. "</xml-trophy>"
  end
}
