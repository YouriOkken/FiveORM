function Where(self, column, value)
    DbHelperFunctions.doesColumnExist(self._table, column)

    table.insert(self._wheres, string.format('`%s` = ?', column))
    table.insert(self._whereParams, value)

    return self
end

function Select(self, ...)
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
function Include(self, fk)
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

function OrderBy(self, column)
    if column ~= nil then
        DbHelperFunctions.doesColumnExist(self._table, column)
    else 
        column = DbHelperFunctions.getPrimaryKey(self._table)
    end

    self._orderBy = column

    return self
end

function OrderByDesc(self, column)
    if column ~= nil then
        DbHelperFunctions.doesColumnExist(self._table, column)
    else 
        column = DbHelperFunctions.getPrimaryKey(self._table)
    end

    self._orderByDesc = column

    return self
end

Builder = {}
function Builder.GetFunctions(instance)
    return {
        Where = function(_, column, value) return Where(instance, column, value) end,
        Select = function(_, ...) return Select(instance, ...) end,
        Include = function(_, fk) return Include(instance, fk) end,
        OrderBy = function(_, column) return OrderBy(instance, column) end,
        OrderByDesc = function(_, column) return OrderByDesc(instance, column) end
    }
end
