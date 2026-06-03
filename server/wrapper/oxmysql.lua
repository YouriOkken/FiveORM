OxMySQL = {}

-- Executes a query without returning results
function OxMySQL.execute(query, params)
    print("OxMySQL.execute called with query: " .. query .. ", params: " .. json.encode(params))
    return MySQL.query(query, params or {})
end

-- Fetches a single row from the database
function OxMySQL.fetch(query, params)
    return exports.oxmysql:fetch_async(query, params or {})
end