-- Only register event handlers if event webhooks are enabled in the configuration.
if Config.Logger.ServerLog.EnableEventWebhooks then
    --- Summary: Handles the 'onResourceStart' event, sending a notification to a webhook.
    ---@param resourceName string The name of the resource that started.
    AddEventHandler('onResourceStart', function (resourceName)
        -- Citizen.Wait(100) -- This wait was present in the original script.
                          -- It can be removed if Config is guaranteed to be immediately available and no delay is intended.
        local messageObject = {
            EventName = 'onResourceStart',
            Message = ("**%s** was started."):format(resourceName),
            Color = Config.Logger.Color["info"]
        }
        SendEventLogPerWebhook(messageObject)
    end)

    --- Summary: Handles the 'onResourceStop' event, sending a notification to a webhook.
    ---@param resourceName string The name of the resource that stopped.
    AddEventHandler('onResourceStop', function (resourceName)
        local messageObject = {
            EventName = 'onResourceStop',
            Message = ("**%s** was stopped."):format(resourceName),
            Color = Config.Logger.Color["info"]
        }
        SendEventLogPerWebhook(messageObject)
    end)
end