local Message = require "app.views.message"

return {
  publish = function(xml)
    print("SENDING: " .. xml)

    network.request(appconfig.api_server_url, "POST", function(event)
      if event.isError then
        Message.toast("Nepodařilo se odeslat :(", { color = "#880000" })
      else
        Message.toast("Úlovek byl odeslán", { color = "#448800" })
      end
    end,
    {
      -- headers = headers,
      body = xml
    })
  end
}
