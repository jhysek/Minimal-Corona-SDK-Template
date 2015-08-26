local Message = require "app.views.message"

return {
  publish = function(xml)
    network.request(appconfig.api_server .. "/upload", "POST", function(event)
      if event.isError then
        Message.toast("Nepodarilo se odeslat :(", { color = "#880000" })
      else
        Message.toast("ODESLANO", { color = "#448800" })
      end
    end,
    {
      -- headers = headers,
      body = xml
    })
  end
}
