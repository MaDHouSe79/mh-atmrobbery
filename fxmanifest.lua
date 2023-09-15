--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'

game 'gta5'

author 'MaDHouSe79'
description 'MH ATM Robbery'

version '1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- change en to your language
    'config.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua',
    'server/update.lua',
}