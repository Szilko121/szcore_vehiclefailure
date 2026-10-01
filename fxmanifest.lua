fx_version 'cerulean'
game 'gta5'
author 'SzCode / SzCore'
version '1.4.0-rc1'
description 'SzCore optimized vehicle damage, tyre failure and repair system'
shared_script 'config.lua'
client_script 'client/main.lua'
server_scripts {'@oxmysql/lib/MySQL.lua','server/main.lua'}
dependencies {'szcore','szcore_inventory','szcore_ui','szcore_vehicles'}
