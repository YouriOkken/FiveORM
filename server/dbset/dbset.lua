DbSet = {}

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
-- DbSet.__index = DbSet

function DbSet.New(tableName)
    DbHelperFunctions.doesTableExist(tableName) -- check if the table exists in the database, if not, throw an error

    local self = {
        _table = tableName,
        _wheres = {},   -- list of conditions
        _whereParams = {},   -- list of values for WHERE ? placeholders
        _query = nil, -- if select function is called, this will be set to the select query instead of the default 'SELECT * FROM table'
        _joins = {}, -- if Include function is called, this will be set to the query to include,
        _joinedTable = nil,
        _thenJoin = {},
        _orderBy = nil,
        _orderByDesc = nil
    }
    
    local Executor = Executor.GetFunctions(self)
    local Builder = Builder.GetFunctions(self)
    local Commands = Commands.GetFunctions(self)

    function self.ToList(_)
        return Executor.ToList(_)
    end

    function self.First(_)
        return Executor.First(_)
    end

    function self.Count(_)
        return Executor.Count(_)
    end

    function self.FindById(_, id)
        return Executor.FindById(_, id)
    end

    function self.Exists(_)
        return Executor.Exists(_)
    end

    function self.Where(_, column, value)
        return Builder.Where(_, column, value)
    end

    function self.Select(_, ...)
        return Builder.Select(_, ...)
    end

    -- @param fk = the foreign key column in the *base* table (e.g. player_id)
    function self.Include(_, fk)
        return Builder.Include(_, fk)
    end

    -- @param fk = the foreign key column in the *included* table (e.g. player_id)
    function self.ThenInclude(_, fk)
        return Builder.ThenInclude(_, fk)
    end

    function self.OrderBy(_, column)
        return Builder.OrderBy(_, column)
    end

    function self.OrderByDesc(_, column)
        return Builder.OrderByDesc(_, column)
    end

    function self.Add(_, data)
        return Commands.Add(_, data);
    end

    function self.Delete(_, value, column)
        return Commands.Delete(_, value, column)
    end

    function self.Update(_, column, value)
        return Commands.Update(_, column, value)
    end

    return self
end