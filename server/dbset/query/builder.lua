function Where(self, column, value)
    if column == nil or value == nil then
        error("Where(): column and value can't be nil", 2)
    end

    DbHelperFunctions.doesColumnExist(self._table, column)

    local clone = DbSet.Clone(self)

    table.insert(clone._wheres, string.format('`%s`.`%s` = ?', self._table, column))
    table.insert(clone._whereParams, value)

    return clone
end

function Select(self, ...)
    local args = {...}

    if args == nil then
        error("Args nill in select", 19)
        
    end
    for _, column in ipairs(args) do
        DbHelperFunctions.doesColumnExist(self._table, column)
    end
    local columns = table.concat(args, ", ")

    local clone = DbSet.Clone(self)

    local query = string.format('SELECT %s.%s FROM `%s`', clone._table, columns, clone._table)
    clone._query = query
    return clone
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

    local clone = DbSet.Clone(self)

    Config.log("join: " .. join)
    table.insert(clone._joins, join)
    clone._joinedTable = referencedTable
    return clone
end

-- @param fk = the foreign key column in the *included* table (e.g. player_id)
function ThenInclude(self, fk)
    if #self._joins == 0 or self._joinedTable == nil then
        error("The Include() function needs to be called before the ThenInclude() function can be called")
        return
    end

    DbHelperFunctions.doesColumnExist(self._joinedTable, fk)

    local clone = DbSet.Clone(self)
    local referencedTable, referencedColumn = DbHelperFunctions.getJoinedTable(clone._joinedTable, fk)

    local join = string.format(
        'LEFT JOIN `%s` ON `%s`.`%s` = `%s`.`%s`',
        referencedTable,
        referencedTable, referencedColumn,
        clone._joinedTable, fk
    )


    Config.log("join: " .. join)
    table.insert(clone._thenJoin, join)
    return clone
end

function OrderBy(self, column)
    if column ~= nil then
        DbHelperFunctions.doesColumnExist(self._table, column)
    else 
        column = DbHelperFunctions.getPrimaryKey(self._table)
    end

    local clone = DbSet.Clone(self)

    clone._orderBy = string.format('`%s`.`%s` = ?', self._table, column)

    return clone
end

function OrderByDesc(self, column)
    if column ~= nil then
        DbHelperFunctions.doesColumnExist(self._table, column)
    else 
        column = DbHelperFunctions.getPrimaryKey(self._table)
    end

    local clone = DbSet.Clone(self)

    clone._orderByDesc = string.format('`%s`.`%s` = ?', self._table, column)

    return clone
end

Builder = {}
function Builder.GetFunctions(instance)
    return {
        Where = function(_, column, value) return Where(instance, column, value) end,
        Select = function(_, ...) return Select(instance, ...) end,
        Include = function(_, fk) return Include(instance, fk) end,
        ThenInclude = function(_, fk) return ThenInclude(instance, fk) end,
        OrderBy = function(_, column) return OrderBy(instance, column) end,
        OrderByDesc = function(_, column) return OrderByDesc(instance, column) end
    }
end
