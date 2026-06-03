Wrapper = {}

function Wrapper.fetchAll(query, params)
    local result
    if (Config.Provider == 'oxmysql') then
        result = MySQL.Sync.fetchAll(query, params)
    end
    
    return result
end