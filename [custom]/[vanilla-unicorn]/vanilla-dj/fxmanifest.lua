fx_version 'cerulean'
game 'gta5'

author 'Gemini'
description 'Vanilla Unicorn DJ System'
version '1.0.0'

shared_script 'config.lua'

client_scripts {'client.lua'}
server_scripts {'server.lua'}

ui_page 'html/index.html'

files {'html/index.html', 'html/style.css', 'html/script.js', 'html/monitor.html' -- ESTA LINHA É OBRIGATÓRIA
}

dependencies {'qb-core', 'qb-target', 'xsound'}
