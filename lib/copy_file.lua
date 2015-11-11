local function doesFileExist( fname, path )
    local results = false
    local filePath = system.pathForFile( fname, path )

    --filePath will be 'nil' if file doesn't exist and the path is 'system.ResourceDirectory'
    if ( filePath ) then
        filePath = io.open( filePath, "r" )
    end

    if ( filePath ) then
        print( "File found: " .. fname )
        --clean up file handles
        filePath:close()
        results = true
    else
        print( "File does not exist: " .. fname )
    end

    return results
end


local function copyFile( srcName, srcPath, dstName, dstPath, overwrite )
    local results = false
    local srcPathExists = doesFileExist( srcName, srcPath )

    if ( srcPathExists == false ) then
        return nil  -- nil = source file not found
    end

    --check to see if destination file already exists
    if not ( overwrite ) then
        if ( doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = file already exists (don't overwrite)
        end
    end

    --copy the source file to the destination file
    local rfilePath = system.pathForFile( srcName, srcPath )
    local wfilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rfilePath, "rb" )
    local wfh = io.open( wfilePath, "wb" )

    if not ( wfh ) then
        print( "writeFileName open error!" )
        return false
    else
        --read the file from 'system.ResourceDirectory' and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "write error!" )
                return false
            end
        end
    end

    results = 2  -- 2 = file copied successfully!

    --clean up file handles
    rfh:close()
    wfh:close()

    return results
end


return {
  copyFile = copyFile,
  doesFileExist = doesFileExist
}

