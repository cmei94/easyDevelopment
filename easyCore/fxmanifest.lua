fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "gta5"
lua54 'yes'
creator "cmei94"
version "3.0.2"



shared_scripts {
	'shared/Config/*.lua',
	'shared/Config/Logger/*.lua',
	'shared/BusinessLogic/Utils/*.lua',
	'shared/ExportFunctions/Utils/*.lua',
	'shared/*.lua'
}

client_script {
	'client/*.lua',
	'client/BusinessLogic/Logger/*.lua',
	'client/ExportFunctions/*.lua',
	'client/ExportFunctions/Cache/*.lua',
	'client/ExportFunctions/LogAndNotify/*.lua',
}

server_scripts {
	'server/*.lua',
	'server/BackgroundServices/*.lua',
	'server/BusinessLogic/LoggerLogic/EventLog/*.lua',
	'server/BusinessLogic/LoggerLogic/*.lua',
	'server/ExportFunctions/*.lua',
	'server/ExportFunctions/Cache/*.lua',
	'server/ExportFunctions/DB/*.lua',
	'server/ExportFunctions/DirectoryFileManager/*.lua',
	'server/ExportFunctions/LogAndNotify/*.lua',
	'server/ExportFunctions/VersionCheck/*.lua',
	
}

dependencies {
    'es_extended',
	'oxmysql',
}