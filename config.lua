Config = Config or {}

Config.Provider = 'oxmysql'
Config.Debug = true

Config.Migrations = true
Config.MigrationTable = "FiveORM_Migrations"

function Config.log(msg)
    if Config.Debug then
        print("[FiveORM Log] " .. msg)
    end
end