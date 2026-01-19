fx_version 'cerulean'
game 'gta5'

author 'ccp development'
description 'Moneywash'
version '1.0.0'

shared_scripts {
  'config.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'client/main.lua'
}

server_scripts {
  '@es_extended/locale.lua',
  'server/main.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/assets/logo.png'
}
