if not Config then
    Config={}
end
if not Config.Logger then
    Config.Logger={}
end

Config.Logger.WebhookLogLevel = "debug" -- Defines the minimum log level for messages to be sent to standard webhooks. 'debug': sends all messages (debug, info, warning, error) 'info': sends info, warning, and error messages 'error': sends only error messages
Config.Logger.AuthorName="easyLogs" -- Defines the author name that will appear in webhook embeds.

--Colors for webhook embeds in decimal format. Use https://www.mathsisfun.com/hexadecimal-decimal-colors.html for conversion.
Config.Logger.Color={
    ["error"]=16711680,  -- Red
    ["warning"]=16776960, -- Yellow
    ["info"]=255,        -- Blue
    ["debug"]=0          -- Black
}

-- Defines standard webhooks for different resources. Format: ["resourceName"] = "webhook_url"
Config.Logger.Webhooks={
   ["easyShop2.0"]="<enter here your webhook>",
   ["easyCore"]="<enter here your webhook>",
   ["easyEconomy"]="<enter here your webhook>",
}

-- Defines event-specific webhooks. These are enabled if Config.Logger.ServerLog.EnableEventWebhooks is true.
Config.Logger.EventWebhooks={
    --general, default and fallback
    ["general"]="<enter here your webhook>",

    --ServerEvents
    ["onResourceStart"]="",
    ["onResourceStop"]="",

    --txAdmin
    ["txAdmin:events:scheduledRestart"]     ="",
    ["txAdmin:events:playerKicked"]         ="",
    ["txAdmin:events:playerWarned"]         ="",
    ["txAdmin:events:playerBanned"]         ="",
    ["txAdmin:events:playerWhitelisted"]    ="",
    ["txAdmin:events:configChanged"]        ="",
    ["txAdmin:events:healedPlayer"]         ="",
    ["txAdmin:events:announcement"]         ="",
    ["txAdmin:events:serverShuttingDown"]   ="",
}