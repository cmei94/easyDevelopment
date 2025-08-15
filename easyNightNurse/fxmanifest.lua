fx_version 'cerulean'
game 'gta5'

name "easyNightNurse"
description "Revive and healing if no ambulance is on duty"
author "Andre, Flo, xBerry, cmei94"
version "2.1.0" -- Version bumped for the refactor
scriptid "easynightnurse"

lua54 'yes'
use_experimental_fxv2_oal 'yes'

licensekey "HIER IST DEIN LIZENZSCHLÜSSEL"
-- English comments for clarity
shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

dependencies {
    'rprogress',
    'easyCore'
}