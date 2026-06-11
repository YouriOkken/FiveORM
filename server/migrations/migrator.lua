local function generateId()
    math.randomseed(os.time())
    return math.random(100000000, 999999999)
end

local function isDir(path)
    local file = path .. "/"
    local ok, err, code = os.rename(file, file)
    return ok, err, code
end

Migrator = {}
function Migrator.generateFile(name, queries)
    local id = generateId()
    local path = GetResourcePath(GetCurrentResourceName())
    path = string.format("%s/migrations", path)
    local pathExists, pathError, code = isDir(path)

    if not pathExists then
        if code == 13 then
            log("Directory was found, but permissions are missing") -- this shouldn't even be triggered, but just in case
        else 
            log(string.format("Path %s not found. Please make sure this is available", path))
        end

        return
    end

    if not name then name = "migration" end

    local file, err = io.open(string.format("%s/%s.sql", path, string.format("%s_%s", id, name)), "w")
    if not file then
        log("Error opening file: " .. err .. ".")
        return
    end
    
    for _, query in ipairs(queries) do
        file:write(query .. "\n\n")
    end

    file:close()
end

function Migrator.build(properties, tableName)
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
            if options.autoIncrement == false then
                line = line .. ' PRIMARY KEY'
            else
                line = line .. ' AUTO_INCREMENT PRIMARY KEY'
            end
        elseif options.unique ~= nil then
            line = line .. ' UNIQUE'
        end

        if options.nullable == false then
            line = line .. ' NOT NULL'
        end

        table.insert(lines, line)
    end

    query = query .. table.concat(lines, ", ") .. ")"
    return query
end

