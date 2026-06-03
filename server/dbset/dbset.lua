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
        _params = {},    -- list of values for ? placeholders,
        _query = nil -- if select function is called, this will be set to the select query instead of the default 'SELECT * FROM table'
    }

    function self.Where(_, column, value)
        DbHelperFunctions.findColumn(self._table, column)

        table.insert(self._wheres, string.format('`%s` = ?', column))
        table.insert(self._params, value)

        return self
    end

    function self.ToList(_)
        local query
        if (self._query == nil) then
            query = string.format('SELECT * FROM `%s`', self._table)
        else 
            query = self._query
        end

        print("query: " .. query)

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

        print("final query: " .. query)
        -- we dont need to add the params since oxmysql will handle that for us when we pass the query and params to it
        local response = Wrapper.fetchAll(query, self._params)
        return response
    end

    function self.Select(_, ...)
        local args = {...}
        for _, column in ipairs(args) do
            DbHelperFunctions.findColumn(self._table, column)
        end
        local columns = table.concat(args, ", ")

        local query = string.format('SELECT %s FROM `%s`', columns, self._table)
        self._query = query
        return self
    end

    function self.Add(_, data)
        local columns = {}
        local placeholders = {}
        local params = {}

        for column, value in pairs(data) do
            DbHelperFunctions.findColumn(self._table, column)
            table.insert(columns, string.format('`%s`', column))
            table.insert(placeholders, '?')
            table.insert(params, value)
        end

        local query = string.format(
            'INSERT INTO `%s` (%s) VALUES (%s)',
            self._table,
            table.concat(columns, ", "),
            table.concat(placeholders, ", ")
        )

        return Wrapper.execute(query, params)
    end

    return self
end