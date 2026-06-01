> Promises 'promise' to give back data
They can have 3 states:
pending: no result yet
resolved: done, result is ready
rejected: something went wrong (error)

example:
```lua
local player = Citizen.Await(getPlayer())
-- Citizen.Await awaits for the promise to give back resolved state


function getPlayer()
    local p = promise.new() -- create the promise

    Citizen.CreateThread(function()
        local results = Citizen.Await(fetch('SELECT * FROM `players`', {})) -- run the query
        p:resolve(results or {}) -- you've got data. resolve the promise and return either the data from the query or an empty table
    end)

    return p -- return the promise so the caller can await it
end
```