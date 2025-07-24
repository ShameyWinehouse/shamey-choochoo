fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts {
	"client/cl_util.lua",
	"client/*.lua",
}
server_scripts {
	"server/*.lua",
	"@oxmysql/lib/MySQL.lua",
}
shared_scripts {
	"config.lua",
	"shared/models/*.lua",
}

files {
	'ui/index.html',
	'ui/style.css',
	'ui/script.js',
	'ui/assets/*',
  }
ui_page 'ui/index.html'

dependencies {
	'rainbow-core',
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'