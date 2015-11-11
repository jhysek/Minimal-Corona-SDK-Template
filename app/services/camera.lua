local class = require "lib.middleclass"
local Camera = class("Camera")


function Camera:onComplete(event)
  local photo = event.target

  if photo then
    print( "photo w,h = " .. photo.width .. "," .. photo.height )
    photo.x = _W / 2
    photo.y = _H / 2
  else
    print("NO PHOTO")
  end


  if self.completedCallback then
    if not photo then
      photo = display.newImage("lastPhoto.png", system.TemporaryDirectory)
    end

    self.completedCallback(photo)
  end
end

function Camera:initialize(command, origin, completed)
  self.cmd = command
  self.completedCallback = completed

  if self:canPerformAction() then
    if command == "take" then
      media.capturePhoto( {
        listener = function(e) self:onComplete(e) end,
        destination = { baseDir=system.TemporaryDirectory, filename="lastPhoto.png", type="image" }
      })
    else
      media.selectPhoto( {
        mediaSource = media.PhotoLibrary,
        listener = function(event) self:onComplete(event) end ,
        destination = { baseDir=system.TemporaryDirectory, filename="lastPhoto.png", type="image" }
      })
    end

  else
    native.showAlert( "Fotoaparát", "Zvolenou akci na tomto zařízení nelze provést.", { "OK" } )
  end
end

function Camera:canPerformAction()
  return (self.cmd == 'take' and self:canTake()) or (self.cmd == 'pick' and self:canPick())
end

function Camera:canTake()
  return media.hasSource( media.Camera)
end

function Camera:canPick()
  return media.hasSource( media.PhotoLibrary )
end


function Camera.take(onDone)
  Camera:new('take', nil, onDone)
end

function Camera.pick(onDone)
  Camera:new('pick', nil, onDone)
end

return Camera
