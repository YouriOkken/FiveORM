DbHelperFunctions = {}

function DbHelperFunctions.doesTableExist(tableName)
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

function DbHelperFunctions.doesColumnExist(tableName, columnName)
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

function DbHelperFunctions.getPrimaryKey(tableName)
    if type(tableName) ~= 'string' then
        error('Table name must be a string')
    end

    local result = Wrapper.fetchAll(
        string.format("SHOW KEYS FROM `%s` WHERE Key_name = 'PRIMARY'", tableName),
        {}
    )

    if not result or #result == 0 then
        error('Table "' .. tableName .. '" does not have a primary key')
    end

    return result[1].Column_name
end

-- @param tableName = name of the table to get the primary key of
-- @param columnName = name of the column to get the primary key of (optional, defaults to 'id')
function DbHelperFunctions.getJoinedTable(tableName, columnName)
    if type(tableName) ~= 'string' then
        error('Table name must be a string')
    end

    local result = Wrapper.fetchAll(
        "SELECT REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = ?  AND COLUMN_NAME = ? AND REFERENCED_TABLE_NAME IS NOT NULL",
        { tableName, columnName }
    )

    if not result or #result == 0 then
        error('Table "' .. tableName .. '" does not have a primary key')
    end

    return result[1].REFERENCED_TABLE_NAME, result[1].REFERENCED_COLUMN_NAME
end