local Files  = require "lib.copy_file"
local base64 = require "lib.base64"

local MEDAL_NUMBERS = {
  none   = 0,
  gold   = 1,
  silver = 2,
  bronze = 3
}


local function os_fields()
  local result = ""
  local os = system.getInfo("platformName")
  local smart_os = os == "Android" and 3 or 2
  local smart_type = system.getInfo("platformName") .. " " .. system.getInfo("platformVersion")

  result = result .. "<smart-os>"   .. smart_os .. "</smart-os>"
  result = result .. "<smart-type>" .. smart_type .. "</smart-type>"
  result = result .. "<smart-user>" .. system.getInfo("deviceID") .. "</smart-user>"
  result = result .. "<orig-lang>"  .. language  .. "</orig-lang>"
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
  if filename and Files.doesFileExist(filename, system.DocumentsDirectory) then
    local path       = system.pathForFile(filename, system.DocumentsDirectory)
    local fh, reason = io.open( path, "r" )
    local content    = base64.encode(fh:read("*a"))

    io.close(fh)
    return "data:image/jpeg;base64," .. content
  else
    return ""
  end
end


return {
  generate = function(rating)
    local code = rating.animal or ""

    print(inspect(rating))
    local result = "<type-evaluation>" .. get_xml_code(code) .. "</type-evaluation>"

    local date_parts = rating.date:split(".")
    local date = string.format("%04d", date_parts[3]) ..
                 string.format("%02d", date_parts[2]) ..
                 string.format("%02d", date_parts[1])

    result = result .. "<age>"     .. (rating.age or "") .. "</age>"
    result = result .. "<dt-hunt>" .. date           .. "</dt-hunt>"
    result = result .. "<hunter>"  .. (rating.hunter or "") .. "</hunter>"
    result = result .. "<place>"   .. (rating.place or "") .. "</place>"
    result = result .. "<country>" .. (rating.country or "").. "</country>"
    result = result .. "<contact>" .. (rating.contact or "") .. "</contact>"

    -- inputs ------------------------------------------------------------------
    local evaluation_data = ""
    InputValue.orderBy = "key"
    InputValue:where({rating_id = rating.id}, function(input)
      tag_name = rating.animal .. "-" .. input.key
      evaluation_data = evaluation_data  .. "<" .. tag_name .. ">" .. ((input.value and input.value * 1000) or "") .. "</".. tag_name ..">"
    end)

    result = result .. "<evaluation-data>" .. evaluation_data .. "</evaluation-data>"

    -- outputs -----------------------------------------------------------------
    result = result .. "<evaluation-plus>"  .. (rating.positive and rating.positive * 1000 or "") .. "</evaluation-plus>"
    result = result .. "<evaluation-minus>" .. (rating.negative and rating.negative * 1000 or "") .. "</evaluation-minus>"
    result = result .. "<evaluation-sum>"   .. (rating.rating and rating.rating * 1000 or "") .. "</evaluation-sum>"
    result = result .. "<medal>"            .. (MEDAL_NUMBERS[rating.medal] or "")   .. "</medal>"

    -- pictures ----------------------------------------------------------------
    result = result .. "<pict-1>" .. encodePhoto(rating.picture3) .. "</pict-1>"
    result = result .. "<pict-2>" .. encodePhoto(rating.picture2) .. "</pict-2>"
    result = result .. "<pict-3>" .. encodePhoto(rating.picture1) .. "</pict-3>"

    -- OS info -----------------------------------------------------------------
    result = result .. "<smart-id>"   .. rating.id .. tostring(rating.created_at) .. "</smart-id>"
    result = result .. os_fields()

    return "<?xml version='1.0' encoding='UTF-8'?><xml-trophy>" .. result .. "</xml-trophy>"
  end
}
