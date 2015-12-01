local Message = require "app.views.message"
local XML     = require "app.services.xml_generator"

local function sendXml(xml, onSuccess, onFail)
  network.request(appconfig.api_server_url, "POST", function(event)
    if event.isError then
      Message.toast("Nepodařilo se odeslat :(", { color = "#880000" })
      if onFail then
        onFail()
      end
    else
      Message.toast("Úlovek byl odeslán", { color = "#448800" })
      if onSuccess then
        onSuccess()
      end
    end
  end,
  {
    -- headers = headers,
    body = xml
  })
end

return {
  publish = sendXml,

  publishRating = function(rating, onSuccess, onFail)
    if rating and appconfig.api_server_url then
      local xml = XML.generate(rating)
      print(inspect(xml))
      sendXml(xml, onSuccess, onFail)
    end
  end

}
