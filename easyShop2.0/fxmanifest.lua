fx_version 'cerulean'
game 'gta5'

name "easyShop"
description "shopSystem for economySystem"
author "easyDevelop"
version "2.0.1"
scriptid "easyshop20"

lua54 'yes'
use_experimental_fxv2_oal 'yes'

licensekey "HIER IST DEIN LIZENZSCHLÜSSEL"

ui_page 'html/index.html'

shared_scripts {
	'shared/main-config.lua',
	'shared/shops-config.lua',
	'shared/init.lua',
}

client_scripts {
	'client/repository/*.lua',
	'client/processor/*.lua',
	'client/init/*.lua',
	'client/*.lua',
}

server_scripts {
	'server/init/init.lua',
	'server/repository/*.lua',
	'server/processor/*.lua',
	'server/*.lua',
}

files {
    'html/*.*',
	'html/images/*.*',
	'@ox_inventory/web/images'
}

dependencies {
	'/onesync',
	'easyCore',
	'easyEconomy',
	'ox_inventory',--needed if ox_inventory used
}
