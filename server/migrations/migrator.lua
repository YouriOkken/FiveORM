-- CREATE TABLE Persons (
--   PersonID int PRIMARY KEY,
--   LastName varchar(255) NOT NULL,
--   FirstName varchar(255),
--   Address varchar(255),
--   City varchar(255)
-- );
local function generateFile(tableName, query) 
    local path = GetResourcePath(GetCurrentResourceName())
    local file, err = io.open(string.format("%s/migrations/%s.sql", path, tableName), "w")
    if not file then
        print("Error opening file: " .. err .. ". This was likely caused by there being no migrations folder in the root directory of the resource")
        return
    end
    file:write(query)
    file:close()
end

local function build(properties, tableName)
    local query = string.format('CREATE TABLE `%s` (', tableName)
    local lines = {}

    for property, options in pairs(properties) do
        local line
        if options.type == "varchar" and options.maxlength ~= nil then
            line = string.format('`%s` %s(%s)', property, options.type, options.maxlength)
        else
            line = string.format('`%s` %s', property, options.type)
        end

        if options.primaryKey ~= nil then
            line = line .. ' PRIMARY KEY'
        end

        if not options.nullable then
            line = line .. ' NOT NULL'
        end

        table.insert(lines, line)
    end

    query = query .. table.concat(lines, ", ") .. ")"
    print("query: " .. query)
    generateFile(tableName, query)
    -- Wrapper.delete(query, { })
end

RegisterCommand("migration", function(source, args, rawCommand)
    local resource = args[1]
    Config.log("resource: " .. resource)
    local resourceState = GetResourceState(resource)
    Config.log("resourceState: " .. resourceState)

    if (resourceState ~= "started") then
        error("Resource is not found or is in a not supported state.")
    end

    local entities = {}
    entities = exports[resource]:SetEntities()
    print(json.encode(entities))
    for _, entity in ipairs(entities) do
        build(entity.properties, entity.tableName)
    end
end, true)

