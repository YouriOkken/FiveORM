Wrapper = {}

function Wrapper.fetchAll(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.fetchAll(query, params)
    end
    
    return result
end

function Wrapper.fetchSingle(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.single.await(query, params)
    end

    return result
end

function Wrapper.insert(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.insert(query, params)
    end

    return result
end

function Wrapper.update(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.execute(query, params)
    end

    return result
end

function Wrapper.delete(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.execute(query, params)
    end

    return result
end

function Wrapper.transaction(queries, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.transaction(queries, params)
    end

    return result
end

function Wrapper.execute(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.execute(query, params)
    end

    return result
end