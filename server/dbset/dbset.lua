DbSet = {}

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
-- DbSet.__index = DbSet

local function copyList(table)
    local result = {}
    for i, value in ipairs(table) do 
        result[i] = value 
    end
    return result
end

function DbSet.New(tableName)
    DbHelperFunctions.doesTableExist(tableName)

    return DbSet.FromState({
        _table = tableName, 
        _wheres = {}, 
        _whereParams = {}, 
        _query = nil,
        _joins = {}, 
        _joinedTable = nil,
        _thenJoin = {},
        _orderBy = nil, 
        _orderByDesc = nil,
    })
end

function DbSet.Clone(src)
    return DbSet.FromState({
        _table       = src._table,
        _wheres      = copyList(src._wheres),
        _whereParams = copyList(src._whereParams),
        _query       = src._query,
        _joins       = copyList(src._joins),
        _joinedTable = src._joinedTable,
        _thenJoin    = copyList(src._thenJoin),
        _orderBy     = src._orderBy,
        _orderByDesc = src._orderByDesc,
    })
end

-- builds a DbSet object (state + methods) from a given state
function DbSet.FromState(state)
    local self = state

    local Executor = Executor.GetFunctions(self)
    local Builder  = Builder.GetFunctions(self)
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