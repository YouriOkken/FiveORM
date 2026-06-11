RegisterCommand("migration", function(source, args, rawCommand)
    if not Config.Migrations then
        print("[FiveORM] Migrations are not enabled in the config!")
        return
    end

    local resource = args[1]
    local resourceState = GetResourceState(resource)
    if (resourceState ~= "started") then
        error("Resource is not found or is in a not supported state.")
    end

    local migrationName = args[2]

    if Config.UniqueMigrationName then
        local path = GetResourcePath(GetCurrentResourceName())
        path = string.format("%s/migrations", path)
        local command = io.popen(string.format('dir "%s" /b', path))
        for file in command:lines() do
            if file ~= "." and file ~= ".." then
                -- all files in the /migrations directory
                local fileName = string.sub(file, string.find(file, "_") + 1)
                local migration = migrationName .. ".sql"

                if migration == fileName then
                    log(string.format("Error: Migration with name %s already exists.", migrationName))
                    return
                end
            end
        end
        command:close()
    end

    local entities = {}
    entities = exports[resource]:SetEntities()

    local queries = {}

    for _, entity in ipairs(entities) do
        local query = Migrator.build(entity.properties, entity.tableName)
        table.insert(queries, query)
    end

    Migrator.generateFile(migrationName, queries)
    log(string.format("Migration %s created!", migrationName))
end, true)

RegisterCommand("run-migrations", function(source, args, rawCommand)
    Runner.RunMigrations()
end, true)