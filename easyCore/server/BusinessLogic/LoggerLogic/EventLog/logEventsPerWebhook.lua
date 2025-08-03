--- Summary: Constructs an event-specific embed and queues it via the webhook handler.
--- It no longer sends the HTTP request directly.
---@param messageObject table A table containing event details.
function SendEventLogPerWebhook(messageObject)
    if not (messageObject and messageObject.EventName) then return end

    -- Determine the webhook URL
    local webhookUrl = Config.Logger.EventWebhooks[messageObject.EventName] or Config.Logger.EventWebhooks['general']

    -- Initialize the embed message structure.
    local embMessage = {
        author = { name = Config.Logger.AuthorName },
        title = "ServerGameplayLog",
        color = messageObject.Color,
        fields = {}
    }

    -- Add standard event fields.
    table.insert(embMessage.fields, { name = "EventName", value = messageObject.EventName, inline = true })
    table.insert(embMessage.fields, { name = "Timestamp", value = os.date('%d-%m-%Y %H:%M:%S'), inline = true })

    -- Dynamically add fields based on messageObject
    if messageObject.PlayerIp then
        table.insert(embMessage.fields, { name = "SpielerIp", value = messageObject.PlayerIp, inline = true })
    end
    if messageObject.PlayerId then
        table.insert(embMessage.fields, { name = "SpielerId", value = messageObject.PlayerId, inline = true })
        table.insert(embMessage.fields, { name = "SpielerName", value = GetPlayerName(messageObject.PlayerId), inline = true })
    end
    if messageObject.OffenderId then
        table.insert(embMessage.fields, { name = "TäterId", value = messageObject.OffenderId, inline = true })
        table.insert(embMessage.fields, { name = "TäterName", value = GetPlayerName(messageObject.OffenderId), inline = true })
    end
    if messageObject.KillerId and messageObject.KillerId ~= 0 then
        table.insert(embMessage.fields, { name = "KillerId", value = messageObject.KillerId, inline = true })
        table.insert(embMessage.fields, { name = "KillerName", value = GetPlayerName(messageObject.KillerId), inline = true })
    end
    if messageObject.PlayerName and not messageObject.PlayerId then
        table.insert(embMessage.fields, { name = "SpielerName", value = messageObject.PlayerName, inline = true })
    end

    -- Add the main log message at the end.
    table.insert(embMessage.fields, { name = "LogMessage", value = messageObject.Message })

    -- Call the exported function from our new handler script to queue the message.
    QueueWebhookMessage(webhookUrl, embMessage)
end