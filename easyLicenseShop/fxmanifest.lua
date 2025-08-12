fx_version 'cerulean'
game 'gta5'

name "easyLicenseShop"
description "Player can buy license (e.g. Isurance)"
author "easyDevelop"
version "1.0.0"
lua54 'yes'
use_experimental_fxv2_oal 'yes'
scriptid 'easylicenseshop'


licensekey "HIER IST DEIN LIZENZSCHLÜSSEL"

ui_page 'html/index.html'

files {
    'html/*.*',
	'html/images/*.*'
}

shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/init/*.lua',
	'server/*.lua',
}

dependencies {
	'/onesync',
	'oxmysql',
	'easyCore',
}
