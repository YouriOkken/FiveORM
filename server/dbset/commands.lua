function Add(self, data)
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

function Delete(self, value, column)
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

function Update(self, column, value)
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

Commands = {}
function Commands.GetFunctions(instance)
    return {
        Add = function(_, data) return Add(instance, data) end,
        Delete = function(_, value, column) return Delete(instance, value, column) end,
        Update = function(_, column, value) return Update(instance, column, value) end
    }
end