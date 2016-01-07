local Message = require "app.views.message"
local XML     = require "app.services.xml_generator"

local function sendXml(xml, rating_id, onSuccess, onFail)
  network.request(appconfig.api_server_url, "POST", function(event)
    if event.isError then
      Rating:update(rating_id, { sync_state = 'error' })
      Message.toast(T:t("messages.trophy_send_failed"), { color = "#880000" })
      if onFail then
        onFail()
      end
    else
      Message.toast(T:t("messages.trophy_sent"), { color = "#448800" })
      Rating:update(rating_id, { sync_state = 'ok' })
      if onSuccess then
        onSuccess()
      end
    end
  end,
  {
    headers = {
      ["Content-Type"] =  "text/xml; charset=utf-8"
    },
    body = xml
  })
end

return {
  publish = sendXml,

  publishRating = function(rating, onSuccess, onFail)
    if rating and appconfig.api_server_url then
      local xml = XML.generate(rating)
      sendXml(xml, rating.id, onSuccess, onFail)
    end
  end

}
