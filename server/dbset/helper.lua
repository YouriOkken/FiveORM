DbHelperFunctions = {}

function DbHelperFunctions.findTable(tableName)
    if type(tableName) ~= 'string' then
        error('Table name must be a string')
    end

    local result = Wrapper.fetchAll(
        "SHOW TABLES LIKE ?",
        { tableName }
    )

    if not result or #result == 0 then
        error('Table "' .. tableName .. '" does not exist in the database')
    end
end

function DbHelperFunctions.findColumn(tableName, columnName)
    if type(tableName) ~= 'string' then
        error('Table name must be a string')
    end

    if type(columnName) ~= 'string' then
        error('Column name must be a string')
    end

    local result = Wrapper.fetchAll(
        "SHOW COLUMNS FROM `" .. tableName .. "` LIKE ?",
        { columnName }
    )

    if not result or #result == 0 then
        error('Column "' .. columnName .. '" does not exist in table "' .. tableName .. '"')
    end
end