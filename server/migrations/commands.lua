RegisterCommand("migration", function(source, args, rawCommand)
    if not Config.Migrations then
        print("[FiveORM] Migrations are not enabled in the config!")
        return
    end

    local resource = args[1]
    local migrationName = args[2]

    local resourceState = GetResourceState(resource)
    if (resourceState ~= "started") then
        error("Resource is not found or is in a not supported state.")
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