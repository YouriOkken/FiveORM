local function getQuery(self)
    local query
    if self._query == nil then
        query = string.format('SELECT * FROM `%s`', self._table)
    else
        query = self._query
    end

    if #self._joins > 0 then
        query = DbHelperFunctions.addJoins(query, self._joins)
    end

    if #self._wheres > 0 then
        query = DbHelperFunctions.addWhere(query, self._wheres)
    end

    return query
end

function ToList(self)
    local query = getQuery(self) -- get the query with the where conditions and joins applied
    local response = Wrapper.fetchAll(query, self._whereParams)
    return response
end

function First(self)
    local query = getQuery(self) .. ' LIMIT 1'
    Config.log("to list query: " .. query)
    local response = Wrapper.fetchSingle(query, self._whereParams)
    return response
end

function Count(self)
    local query = string.format('SELECT COUNT(*) as count FROM `%s`', self._table)
    
    if #self._wheres > 0 then
        query = DbHelperFunctions.addWhere(query, self._wheres)
    end

    local result = Wrapper.fetchSingle(query, self._whereParams)
    return result.count
end

Executor = {}
function Executor.GetFunctions(instance)
    return {
        ToList = function() return ToList(instance) end,
        First = function() return First(instance) end,
        Count = function() return Count(instance) end
    }
end
