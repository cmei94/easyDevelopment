fx_version "adamant"
game "gta5"
lua54 'yes'
creator "cmei94"
version "3.0.3"
scriptid "easycore"


licensekey "HIER IST DEIN LIZENZSCHLÜSSEL"



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
	'server/initEasyCore.lua',
	'server/BackgroundServices/*.lua',
	'server/BusinessLogic/LoggerLogic/EventLog/*.lua',
	'server/BusinessLogic/LoggerLogic/*.lua',
	'server/ExportFunctions/*.lua',
	'server/ExportFunctions/Cache/*.lua',
	'server/ExportFunctions/DB/*.lua',
	'server/ExportFunctions/DirectoryFileManager/*.lua',
	'server/ExportFunctions/LogAndNotify/*.lua',
	'server/initValidate.lua'
}

dependencies {
    'es_extended',
	'oxmysql',
}