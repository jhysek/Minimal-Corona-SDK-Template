local mime = require("mime")
local base64 = {}

function base64.encode(data)
  local len = data:len()
  local t = {}
  for i=1,len,384 do
    local n = math.min(384, len+1-i)
    if n > 0 then
      local s = data:sub(i, i+n-1)
      local enc, _ = mime.b64(s)
      t[#t+1] = enc
    end
  end

  return table.concat(t)
end

function base64.decode(data)
  local len = data:len()
  local t = {}
  for i=1,len,384 do
    local n = math.min(384, len+1-i)
    if n > 0 then
      local s = data:sub(i, i+n-1)
      local dec, _ = mime.unb64(s)
      t[#t+1] = dec
    end
  end
  return table.concat(t)
end

return base64
