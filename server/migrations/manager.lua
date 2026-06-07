local function doesTableExist(tableName)
    local result = Wrapper.fetchAll(
        "SHOW TABLES LIKE ?",
        { tableName }
    )

    if not result or #result == 0 then
        return false
    end

    return true
end

local function checkForMigrationsTable()
    local exists = doesTableExist(Config.MigrationTable)

    if not exists then
        log("Migration table not found. Creating...")

        local query = string.format("CREATE TABLE `%s` (Migration varchar(100) NOT NULL UNIQUE);", Config.MigrationTable)
        Config.log("Creating migration table with query: " .. query)
        Wrapper.execute(query, {})
        log("Migration table created!")
    else 
        log("migration table found")
    end
end

local function isDir(path)
    local file = path .. "/"
    local ok, err, code = os.rename(file, file)
    return ok, err, code
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if Config.Migrations then
            local path = GetResourcePath(GetCurrentResourceName())
            path = string.format("%s/migrations", path)
            local pathExists, pathError, code = isDir(path)

            if not pathExists then
                if code == 13 then
                    log("Directory was found, but permissions are missing") -- this shouldn't even be triggered, but just in case
                else 
                    print(string.format("Path %s not found. Please make sure this is available", path))
                end

                return
            end
            checkForMigrationsTable()
        end
    end
end)