-- Executes a query without returning results
local function execute(query, params)
    return exports.oxmysql:execute_async(query, params or {})
end

-- Fetches a single row from the database
local function fetch(query, params)
    return exports.oxmysql:fetch_async(query, params or {})
end

return {
    execute = execute,
    fetch   = fetch,
}