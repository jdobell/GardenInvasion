local file = {}

-- Function to save a table.&nbsp; Since game settings need to be saved from session to session, we will
-- use the Documents Directory

local json = require("json")
function file.saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
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

function file.loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         myTable = json.decode(contents);
         io.close( file )
         return myTable 
    end
    return nil
end

function file.saveLevelData(t, filename)
    local contents = file.loadTable(filename)
    local found = false

    if(contents) then
        for k,v in pairs(contents) do
            if(v.level == t.level) then
                contents[k].score = t.score
                found = true
            end
        end
    else
        contents = {}
    end

    if(found == false) then
        table.insert(contents, t)
    end
    file.saveTable(contents, filename)
end
return file