local function doesMigrationExist(name)
    local query = string.format("SELECT `Migration` FROM `%s` WHERE `Migration` = ? ", Config.MigrationTable) 
    local found = Wrapper.fetchSingle(query, { name })
    
    if found then
        return true
    end
    
    return false
end

local function getRunnableMigrations()
    local migrations = {}
    local path = GetResourcePath(GetCurrentResourceName())
    path = string.format("%s/migrations", path)
    local command = io.popen(Runner.GetListCommand(path))
    for file in command:lines() do
        if file ~= "." and file ~= ".." then
            -- all files in the /migrations directory
            local doesMigrationExist = doesMigrationExist(file)

            if not doesMigrationExist then
                table.insert(migrations, file)
            end
        end
    end
    command:close()

    return migrations
end

Runner = {}
function Runner.GetListCommand(path)
    local isWindows = path:match('^%a:') ~= nil

    if isWindows then
        return string.format('dir "%s" /b', path)
    end
    return string.format('ls -1 "%s"', path)
end

function Runner.RunMigrations()
    local migrations = getRunnableMigrations()
    table.sort(migrations)
    local migrationCount = #migrations

    if migrationCount == 0 then
        log("No migrations found.")
        return
    end

    local path = GetResourcePath(GetCurrentResourceName())
    path = string.format("%s/migrations", path)
    log(string.format("Running %s migrations", migrationCount))
    for _, migration in ipairs(migrations) do
        local file = io.open(path .. "/" .. migration, "r")
        local content = file:read("*a")
        file:close()

        local queries = {}

        for statement in content:gmatch("[^\n]+") do
            if statement ~= "" then
                table.insert(queries, { query = statement, values = {} })
            end
        end

        -- add the migration registration as the last query in the transaction
        table.insert(queries, {
            query = string.format("INSERT INTO `%s` (`Migration`) VALUES (?)", Config.MigrationTable),
            values = { migration }
        })

        local success = Wrapper.transaction(queries)
        if success then
            Config.log("Migration " .. migration .. " ran successfully")
        else
            error("Migration " .. migration .. " failed")
            return
        end
    end

    log(string.format("Successfully executed %s migrations", migrationCount))
end