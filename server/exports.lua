local function FetchAll(tableName)
    return DbSet.New(tableName):ToListAsync()
end

exports("FetchAll", function(...)
    print("Resource " .. GetInvokingResource() .. " executed FetchAll export")
    return FetchAll(...)
end)