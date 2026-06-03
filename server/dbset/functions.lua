DBFunctions = {}

function DBFunctions.findTable(tableName)
    if type(tableName) ~= 'string' then
        error('Table name must be a string')
    end

    print("Finding table: " .. tableName)
    print("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?, params: " .. json.encode({ tableName }))
    local result = Citizen.Await(OxMySQL.fetch(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ? AND TABLE_SCHEMA = DATABASE()",
        { tableName }
    ))

    if not result or #result == 0 then
        error('Table "' .. tableName .. '" does not exist in the database')
    end
end