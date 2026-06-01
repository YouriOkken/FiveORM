local DbSet = {}
local wrapper = require "server/wrapper/oxmysql"
local functions = require "dbset/functions"

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
DbSet.__index = DbSet 

function DbSet.New(tableName)
    functions.findTable(tableName) -- check if the table exists, will throw an error if it doesn't

    return setmetatable({
        _table = tableName,
    }, DbSet)
end

function DbSet:ToListAsync()
    local p = promise.new()

    Citizen.CreateThread(function()
        local query   = string.format('SELECT * FROM `%s`', self._table) -- self._table is the table name we set when creating the DbSet
        local results = Citizen.Await(wrapper.fetch(query, {})) -- execute the query and wait for the results
        p:resolve(results or {}) -- resolve the promise with the results, or an empty table if there are no results
    end)

    return p
end

-- Example usage:
local Player = DbSet.New('players')