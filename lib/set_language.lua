require "lib.settings"

local translations =
{
    ["test"] =
    {
        ["en"] = "test",
        ["cs"] = "test",
    },
}

function setLanguage(lang_code)
    local conf = loadTable("user_settings")

    if lang_code then
      conf.language = lang_code
      saveTable(conf, "user_settings")
    end

    if conf.language == nil then
        language = system.getPreference("ui", "language")

        if string.len(language) > 2 then
          language = system.getPreference('locale', 'language')
        end

        if (translations["test"][language]) == nil then
           language = "en"

           conf.language = language
           saveTable(conf, "user_settings")

           print ("UI language supported - Saving " .. language .. " to settings.json")
        else
           conf.language = language
           saveTable(conf, "user_settings")

           print ("UI language supported - Saving " .. language .. " to settings.json")
        end
    else
       language = conf.language
       print ("restored language " .. language .. " from settings.json")
    end
end

