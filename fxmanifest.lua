fx_version 'cerulean'
game 'gta5'

name 'FiveORM'
description 'A simple Entity Framework inspired ORM for FiveM'
version '1.0.1'

server_scripts {
    'server/wrapper/oxmysql.lua',
    'server/dbset/functions.lua',
    'server/dbset/dbset.lua',
    'server/exports.lua',
    '@oxmysql/lib/MySQL.lua'
}