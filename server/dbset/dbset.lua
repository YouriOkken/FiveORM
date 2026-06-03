DbSet = {}

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
DbSet.__index = DbSet

function DbSet.New(tableName)
    print("Creating DbSet for table: " .. tableName)
    -- DBFunctions.findTable(tableName) -- check if the table exists, will throw an error if it doesn't

    return setmetatable({
        _table = tableName,
    }, DbSet)

    function self:ToListAsync()
        local response = MySQL.Sync.fetchAll(
            string.format('SELECT `firstname`, `lastname` FROM `%s`', self._table),
            {}
        )
        return response
    end
end


RegisterCommand("dbsettest", function()
    local db = DbSet.New("users")  -- store the instance
    print("Testing DbSet:ToListAsync()")
    local result = db:ToListAsync()  -- call on the instance, not the class
    print(json.encode(result))
end, false)