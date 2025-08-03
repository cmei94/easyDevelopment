fx_version 'cerulean'
game 'gta5'
name "easyEconomy"
description "manage variable item prizes by supply and demand"
author "cmei94"
version "2.0.5"
lua54 'yes'
use_experimental_fxv2_oal 'yes'
scriptid "easyeconomy"


licensekey "HIER IST DEIN LIZENZSCHLÜSSEL"

ui_page 'html/index.html'


files {
    'html/*.*',
	'html/images/*.*',
	'@ox_inventory/web/images'
}

shared_scripts {
	'shared/classes/*.lua',
	'shared/*.lua'
	
}

client_scripts {
	'client/repository/*.lua',
	'client/processor/*.lua',
	'client/init/*.lua',
	'client/*.lua',
}

server_scripts {
	'@ox_inventory/data/items.lua',
	'server/repository/*.lua',
	'server/processor/EconomyHookProcessor.lua',
	'server/processor/EconomyCalculationProcessor.lua',
	'server/processor/EconomyServerSideProcessor.lua',
	'server/init/db_initHelper.lua',
	'server/init/db_init.lua',
	'server/*.lua'
}

files {
	'@ox_inventory/data/*.lua'--needed if ox_inventory used
}

dependencies {
	'/onesync',
	'oxmysql',
	'easyCore',
	'ox_inventory',--needed if ox_inventory used
}