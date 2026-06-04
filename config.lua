Config = Config or {}

Config.Provider = 'oxmysql' -- 'oxmysql' or 'mysql-async' <-- mysql-async not available yet
Config.Debug = true

function Config.log(msg)
    if Config.Debug then
        print("[FiveORM] " .. msg)
    end
end