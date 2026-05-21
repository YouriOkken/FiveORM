local ORM = {}

-- oxmysql wrapper functions

-- Executes a query without returning results
local function execute(query, params)
    return exports.oxmysql:execute_async(query, params or {})
end

-- Fetches a single row from the database
local function fetch(query, params)
    return exports.oxmysql:fetch_async(query, params or {})
end

-- Dummy entity to give an idea of what a player object should look like
function ORM.CreatePlayer(data)
    return {
        identifier = data.identifier,
        name       = data.name,
        money      = data.money or 0,
    }
end

-- Saves a player to the database
function ORM.InsertPlayer(player)
    -- make a new promise
    local p = promise.new()

    Citizen.CreateThread(function()
        local query = 'INSERT INTO `players` (`identifier`, `name`, `money`) VALUES (?, ?, ?)'

        Citizen.Await(execute(query, {
            player.identifier,
            player.name,
            player.money,
        }))

        p:resolve(player)
    end)

    return p
end

function ORM.GetAllPlayers()
    local p = promise.new()

    Citizen.CreateThread(function()
        local results = Citizen.Await(fetch('SELECT * FROM `players`', {}))
        p:resolve(results or {})
    end)

    return p
end