-- ads -----------------------------------------------------
ads = require "ads"

local setting = Setting:first() or { premium = false }
premium = setting.premium
banner_height = 0

if not premium then
  local ads_provider
  local banner_position

  ----------------------------------------------------------
  showAd = function( adType, position )
    local adX = display.screenOriginX
    local adY = display.screenOriginY

    banner_position = position
    if position == "bottom" then
      adY = adY + display.actualContentHeight - 65
    end

    ads.show( adType, { x = adX, y = adY } )

    banner_height = 60
  end

  ----------------------------------------------------------
  local function adListener( event )
  end

  ----------------------------------------------------------
  print("AD INIT: " .. appconfig.admob.code)
  ads.init( "admob", appconfig.admob.code, adListener )
  ads:setCurrentProvider("admob")

  local onSystem = function( event )
    if event.type == "applicationResume" then
      ads:setCurrentProvider("admob")
      showAd("banner", banner_position)
    end
  end

  Runtime:addEventListener( "system", onSystem )
end

