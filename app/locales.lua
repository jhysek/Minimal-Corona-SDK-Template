local json = require "json"

local translations = loadTable("config/texts.json", system.ResourceDirectory) or {}

local default_language = "cs"

function translations:t(text, default)
  if self[text] and self[text][language] then
    return self[text][language]
  elseif self[text] and self[text][default_language] then
    return self[text][default_language]
  else
    return default or text
  end
end

return translations
