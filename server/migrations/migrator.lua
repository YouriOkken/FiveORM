local integerTypes = { int = true, bigint = true, smallint = true, tinyint = true, mediumint = true }

local function generateId()
    return os.date('%Y%m%d%H%M%S')
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
        if options.type == "varchar" then
            local length = options.maxlength or 255
            line = string.format('`%s` varchar(%s)', property, length)
        else
            line = string.format('`%s` %s', property, options.type)
        end

        if options.primaryKey == true then
            local isInteger = integerTypes[options.type] == true

            if options.autoIncrement == true and not isInteger then
                error(string.format("AUTO_INCREMENT is only allowed on integer columns ('%s' is %s)", property, options.type), 2)
            end

            if isInteger and options.autoIncrement ~= false then
                line = line .. ' AUTO_INCREMENT PRIMARY KEY'
            else
                line = line .. ' PRIMARY KEY'
            end
        elseif options.unique == true then
            line = line .. ' UNIQUE'
        end

        if options.nullable == false then
            line = line .. ' NOT NULL'
        end

        table.insert(lines, line)
    end

    return query .. table.concat(lines, ", ") .. ")"
end