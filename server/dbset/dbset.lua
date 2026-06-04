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
        _joins = {} -- if Include function is called, this will be set to the query to include
    }

    function self.Where(_, column, value)
        DbHelperFunctions.doesColumnExist(self._table, column)

        table.insert(self._wheres, string.format('`%s` = ?', column))
        table.insert(self._whereParams, value)

        return self
    end

    local function getQuery() 
        local query
        if (self._query == nil) then
            query = string.format('SELECT * FROM `%s`', self._table)
        else 
            query = self._query
        end

        Config.log("query: " .. query)

        if (#self._joins > 0) then
            query = DbHelperFunctions.addJoins(query, self._joins)
        end

        if (#self._wheres > 0) then -- if where table is not empty, add it to the query
            query = DbHelperFunctions.addWhere(query, self._wheres)
        end

        Config.log("final query: " .. query)

        return query
    end

    function self.ToList(_)
        local query = getQuery() -- get the query with the where conditions and joins applied
        local response = Wrapper.fetchAll(query, self._whereParams)
        return response
    end

    function self.First(_)
        local query = getQuery() .. ' LIMIT 1'
        Config.log("to list query: " .. query)
        local response = Wrapper.fetchSingle(query, self._whereParams)
        return response
    end

    function self.Select(_, ...)
        local args = {...}
        for _, column in ipairs(args) do
            DbHelperFunctions.doesColumnExist(self._table, column)
        end
        local columns = table.concat(args, ", ")

        local query = string.format('SELECT %s.%s FROM `%s`', self._table, columns, self._table)
        self._query = query
        return self
    end

    -- @param fk = the foreign key column in the *base* table (e.g. player_id)
    function self.Include(_, fk)
        DbHelperFunctions.doesColumnExist(self._table, fk)

        local referencedTable, referencedColumn = DbHelperFunctions.getJoinedTable(self._table, fk)

        local join = string.format(
            'LEFT JOIN `%s` ON `%s`.`%s` = `%s`.`%s`',
            referencedTable,
            referencedTable, referencedColumn,
            self._table, fk
        )

        Config.log("join: " .. join)
        table.insert(self._joins, join)
        return self
    end

    function self.Add(_, data)
        local columns = {}
        local placeholders = {}
        local params = {}

        for column, value in pairs(data) do
            DbHelperFunctions.doesColumnExist(self._table, column)
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

        return Wrapper.insert(query, params)
    end

    function self.Delete(_, value, column)
        local query

        if column == nil then
            -- Delete(id) -- assume column is the id value
            column = DbHelperFunctions.getPrimaryKey(self._table)
            Config.log("column was nil")
            Config.log("primary key: " .. column)
        else
            -- Delete(column, value)
            Config.log("column was not nil")
            Config.log("column: " .. column)
            DbHelperFunctions.doesColumnExist(self._table, column)
        end

        Config.log("value: " .. tostring(value))

        query = string.format('DELETE FROM `%s` WHERE `%s` = ?', self._table, column)
        Config.log("delete query: " .. query)
        Wrapper.delete(query, { value })
    end

    function self.Update(_, column, value)
        if (self._wheres == nil or #self._wheres == 0) then
            error('Update operation requires at least one Where condition to prevent mass updates.')
        end
        if (self._whereParams == nil or #self._whereParams == 0) then
            error('Where conditions must have corresponding parameters for Update operation.')
        end

        DbHelperFunctions.doesColumnExist(self._table, column)

        local query = string.format('UPDATE `%s` SET `%s` = ? ', self._table, column)
        query = DbHelperFunctions.addWhere(query, self._wheres)

        Config.log("final update query: " .. query)
        Config.log("update params: " .. json.encode(self._whereParams) .. ", " .. tostring(value))
        Wrapper.update(query, { value, table.unpack(self._whereParams) })
    end

    return self
end