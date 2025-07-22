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
   --["easyNPC"]="https://discord.com/api/webhooks/1155125802594222240/X3cYJNgDZpFQM2qn-rt1lVsfenhberfqMDdRRA046HlDkFBBWUBxpxnIUihH2cH8Qte1",
   ["top-games-vote-plugin"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2",
   ["easyShop2.0"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2",
   ["easyCore"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2",
   ["easyEconomy"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2",
   ["easyEconomicSystem"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2",
}

-- Defines event-specific webhooks. These are enabled if Config.Logger.ServerLog.EnableEventWebhooks is true.
Config.Logger.EventWebhooks={
    --general, default and fallback
    ["general"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",

    --ServerEvents
    ["onResourceStart"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["onResourceStop"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",

    --player events
    ["playerConnecting"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["playerDropped"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["chatMessage"]="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",

    --client triggered events
    ["easyLogs:playerDied"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2", --enabled if Config.ServerLog.EnableDeathLog is true
    ["easyLogs:PlayerDamage"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2", --enabled if Config.ServerLog.EnableDamageLog is true
    ["easyLogs:playerShotWeapon"]="https://discord.com/api/webhooks/1257400751723122699/7NyCOnlTFxZp1BGJc2I9tMSkhWsuNrAX_YEZc8KKbdxWZ2SpzSeCh_x0402_zLKe9Vo2", --enabled if Config.ServerLog.EnableShootingLog is true
    
    --txAdmin
    ["txAdmin:events:scheduledRestart"]     ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:playerKicked"]         ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:playerWarned"]         ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:playerBanned"]         ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:playerWhitelisted"]    ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:configChanged"]        ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:healedPlayer"]         ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:announcement"]         ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
    ["txAdmin:events:serverShuttingDown"]   ="https://discord.com/api/webhooks/1240925080704520212/eWZZPmmt6-YX6bqWdWh3MQD84SyvtiGjp8zoMt47wnymkxJWh9kfz_BKS1c3MCssYS07",
}