fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Gemini AI'
description 'Sistema MDT/CAD Profissional'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- ESTA LINHA RESOLVE O TEU ERRO
    'server/main.lua'
}