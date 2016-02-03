-- ads -----------------------------------------------------
ads = require "ads"

local setting = Setting:first() or { premium = false, with_ads = true }
premium = Purchase:count() > 0 and not setting.with_ads
banner_height = 0

local ads_provider
local banner_position

----------------------------------------------------------
showAd = function( adType, position )
  if not premium then
    local adX = display.screenOriginX
    local adY = display.screenOriginY

    banner_position = position
    if position == "bottom" then
      adY = adY + display.actualContentHeight - 55
    end

    ads.show( adType, { x = adX, y = adY } )

    banner_height = 55
  end
end

----------------------------------------------------------
local function adListener( event )
end

----------------------------------------------------------
if not premium then
  local code = appconfig.admob_code.ios
  if (system.getInfo( "platfromName" ) == "Android") then
    code = appconfig.admob_code.android
  end

  print("AD INIT: " .. code)
  ads.init( "admob", code, adListener )
  ads:setCurrentProvider("admob")
end

local onSystem = function( event )
  if not premium then
    if event.type == "applicationResume" then
      ads:setCurrentProvider("admob")
      showAd("banner", banner_position)
    end
  end
end

Runtime:addEventListener( "system", onSystem )

