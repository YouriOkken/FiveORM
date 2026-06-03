DBFunctions = {}

function DBFunctions.findTable(tableName)
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