local json = require("json")

function saveTable(t, filename, dir)
  local path = system.pathForFile( filename, dir or system.DocumentsDirectory)
  local file = io.open(path, "w")
  if file then
    local contents = json.encode(t)
    file:write( contents )
    io.close( file )
    return true
  else
    return false
  end
end

function loadTable(filename, dir)
  local path = system.pathForFile( filename, dir or system.DocumentsDirectory)
  local contents = ""
  local myTable = {}
  local file = io.open( path, "r" )

  if file then
    local contents = file:read( "*a" )
    myTable = json.decode(contents)
    io.close( file )
    return myTable
  end
  return {}
end
