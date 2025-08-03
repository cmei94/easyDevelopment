if not Config then
    Config={}
end
if not Config.Logger then
    Config.Logger={}
end

Config.Logger.MessageLogLevels={ -- Defines the valid message log levels.
    "debug",
    "info",
    "warning",
    "error"
}

Config.Locale="de"  -- Configures the locale for the logger (e.g., for language-specific formatting).

--ServerSideLog
Config.Logger.ServerLog = {}
Config.Logger.ServerLog.Enable = true -- Enables or disables server-side logging entirely.
Config.Logger.ServerLog.LogFile = {}
Config.Logger.ServerLog.LogFile.Enable = true -- Enables or disables logging to individual resource log files.
Config.Logger.ServerLog.LogFile.LogLevel = "debug" -- Sets the minimum log level for individual resource log files. 'debug'=all ('debug','info','warning','error') 'info'=info and error 'error'=just error
Config.Logger.ServerLog.Console = {}
Config.Logger.ServerLog.Console.LogLevel = "debug" -- Sets the minimum log level for console output. 'debug'=all ('debug','info','warning','error') 'info'=info and error 'error'=just error
Config.Logger.ServerLog.TotalLog = {} 
Config.Logger.ServerLog.TotalLog.Enable = true -- Enables or disables logging to a single total log file.
Config.Logger.ServerLog.TotalLog.Name = "TotalLog" -- Defines the name for the total log file.
Config.Logger.ServerLog.TotalLog.LogLevel = "debug" -- Sets the minimum log level for the total log file. 'debug'=all ('debug','info','warning','error') 'info'=info and error 'error'=just error

--ENABLE Logs
Config.Logger.ServerLog.EnableWebhooks=true -- Enables or disables sending standard logs to webhooks.
Config.Logger.ServerLog.EnableEventWebhooks=false -- Enables or disables sending event-specific logs to webhooks.
Config.Logger.ServerLog.EnableAutoLogFileDelete=true -- Enables or disables automatic deletion of old log files.
Config.Logger.ServerLog.EnableAutoLogFileDeleteTimeInHours=7*24 -- Sets the time in hours after which log files will be automatically deleted. Minimum is 24 hours.
 
--LogWhitLists
Config.Logger.WeaponsNotLogged = { -- for Config.ServerLog.EnableShootingLog (if implemented)
    "WEAPON_SNOWBALL",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN"
}

--PerformanceLog --NOT IMPLEMENTED YET
Config.Logger.PerfLog = {}
Config.Logger.PerfLog.Enable = false