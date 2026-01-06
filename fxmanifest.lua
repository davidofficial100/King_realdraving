fx_version 'cerulean'
game 'gta5'

author 'King Development'
description 'Complete realistic driving system with terrain, tire, and vehicle damage'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/terrain.lua',
    'client/ignition.lua',
    'client/autopilot.lua',
    'client/damage.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    '/server:7290'
}
