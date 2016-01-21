local json    = require "json"
local Message = require "app.views.message"
local XML     = require "app.services.xml_generator"

local function activateAll()
  form_definitions = loadTable("config/form_definitions.json", system.ResourceDirectory) or {sections = {}}

  for i = 1, #form_definitions.sections do
    local definition = form_definitions.sections[i]
    if definition.inapp_code then
      Purchase:insert({ product = definition.inapp_code });
    end
  end

  Message.toast(T:t("messages.service_info_activated"), { color = "#448800" })
end


local function sendServiceInfo(xml, onSuccess, onFail)
  network.request(appconfig.api_server_url .. "/service-info", "POST", function(event)
    if event.isError then
      Message.toast(T:t("messages.service_info_fail"), { color = "#880000" })
      if onFail then
        onFail()
      end
    else
      local response = json.decode(event.response)
      print(inspect(response))
      if response.enable_voucher == 1 then
        activateAll()
      else
        Message.toast(T:t("messages.service_info_sent"), { color = "#448800" })
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

local function sendXml(xml, rating_id, onSuccess, onFail)
  network.request(appconfig.api_server_url .. "/xml", "POST", function(event)
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
  end,

  publishServiceInfo = function(onSuccess, onFail)
    local xml = XML.service_info()
    sendServiceInfo(xml, onSuccess, onFail)
  end

}
