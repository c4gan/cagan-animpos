fx_version "cerulean"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

name "cagan-animpos"
author "cagan"
version "1.0.0"

ui_page "ui/index.html"

files {
    "ui/index.html",
    "ui/css/*.css",
    "ui/js/*.js",
    "ui/lib/*.js"
}

shared_scripts {
    "config.lua",
    "shared/locale.lua",
    "locales/*.lua"
}

client_scripts {
    "client/bridge.lua",
    "client/editable.lua",
    "client/animpos.lua",
    "client/main.lua"
}

server_scripts {
    "server/bridge.lua",
    "server/main.lua"
}
