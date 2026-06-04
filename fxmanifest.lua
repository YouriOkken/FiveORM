fx_version 'cerulean'
game 'gta5'

name 'FiveORM'
description 'A simple Entity Framework inspired ORM for FiveM'
version '1.0.1'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/wrapper/wrapper.lua',
    'server/dbset/helper.lua',
    'server/functions.lua',
    'server/dbset/query/builder.lua',
    'server/dbset/query/executor.lua',
    'server/dbset/commands.lua',
    'server/dbset/dbset.lua',
    'server/exports.lua',
}