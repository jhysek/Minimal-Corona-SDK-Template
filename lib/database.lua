local sqlite3 = require "sqlite3"
local Model   = require "lib.Model"

local Database = {}
Database_mt = { __index = Object }

function Database:create(filename)
  local new_inst = {}
  local group = display.newGroup()
  new_inst.group = group

  setmetatable(new_inst, Database)

  local path = system.pathForFile((filename or "data.db"), system.DocumentsDirectory )
  new_inst.db = sqlite3.open( path )

  function new_inst:newModel(tableName, attributes)
    return Model:new(self.db, tableName, attributes)
  end

  local function onSystemEvent( event, db )
    if ( event.type == "applicationExit" ) then
      db:close()
    end
  end

  -- -----------------------------------------
  Runtime:addEventListener( "system", function(e) onSystemEvent(e, new_inst.db) end)

  -- -----------------------------------------
  return new_inst
end

return Database






