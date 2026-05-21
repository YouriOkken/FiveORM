local DbSet = {}

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
DbSet.__index = DbSet 

function DbSet.New(tableName)
    return setmetatable({
        _table = tableName,
    }, DbSet)
end

function DbSet:ToListAsync()
    local p = promise.new()

    Citizen.CreateThread(function()
        local query   = string.format('SELECT * FROM `%s`', self._table)
        local results = Citizen.Await(exports.oxmysql:fetch_async(query, {}))
        p:resolve(results or {})
    end)

    return p
end

-- Example usage:
local Player = DbSet.New('players')