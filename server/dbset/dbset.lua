DbSet = {}

-- __index tells Lua: "if a method is not found on the instance,
-- look it up on DbSet itself" -- this is how Lua does inheritance/OOP.
-- Without this, calling Player:ToListAsync() would return nil.
-- DbSet.__index = DbSet

function DbSet.New(tableName)
    DbHelperFunctions.findTable(tableName) -- check if the table exists in the database, if not, throw an error

    local self = {
        _table = tableName,
        _wheres = {},   -- list of conditions
        _params = {}    -- list of values for ? placeholders
    }

    function self.Where(_, column, value)
        table.insert(self._wheres, string.format('`%s` = ?', column))
        table.insert(self._params, value)

        return self
    end

    function self.ToListAsync(_)
        local query = string.format('SELECT * FROM `%s`', self._table)

        if (#self._wheres > 0) then -- if where table is not empty, add it to the query
            local whereClause = "WHERE "
            for i, condition in ipairs(self._wheres) do -- loop through conditions and add them to the where clause
                whereClause = whereClause .. condition -- add condition to where clause
                if i < #self._wheres then -- if it's not the last condition, add AND
                    whereClause = whereClause .. " AND " 
                end
            end
            query = query .. " " .. whereClause -- add where clause to query
        end

        -- we dont need to add the params since oxmysql will handle that for us when we pass the query and params to it
        local response = Wrapper.fetchAll(query, self._params)
        return response
    end

    return self
end