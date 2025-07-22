--- Summary: Sends an event-specific log message to a configured Discord webhook.
--- It constructs a Discord embed message with relevant event details.
---@param messageObject table A table containing event details such as EventName, Message, Color, PlayerId, etc.
function SendEventLogPerWebhook(messageObject)
    -- Ensure messageObject and EventName are valid.
    if messageObject and messageObject.EventName then
        -- Determine the webhook URL, falling back to 'general' if a specific one is not found.
        local webhookUrl = Config.Logger.EventWebhooks[messageObject.EventName]
        if not webhookUrl then
            webhookUrl = Config.Logger.EventWebhooks['general']
        end

        -- Initialize the embed message structure.
        local embMessage = {
            author = { name = Config.Logger.AuthorName },
            title = "ServerGameplayLog",
            color = messageObject.Color,
            fields = {} -- Initialize the fields table.
        }

        -- Add standard event fields.
        table.insert(embMessage.fields, {
            name = "EventName",
            value = messageObject.EventName,
            inline = true
        })
        local currentTime = os.time()
        local now = os.date('%d-%m-%Y %H:%M:%S', currentTime)
        table.insert(embMessage.fields, {
            name = "Timestamp",
            value = now,
            inline = true
        })

        -- Dynamically add fields based on the presence of keys in messageObject.
        -- Fields are added in a specific order for consistency.

        if messageObject.PlayerIp then
            table.insert(embMessage.fields, {
                name = "SpielerIp",
                value = messageObject.PlayerIp,
                inline = true
            })
        end

        if messageObject.PlayerId then
            local playerName = GetPlayerName(messageObject.PlayerId)
            table.insert(embMessage.fields, {
                name = "SpielerId",
                value = messageObject.PlayerId,
                inline = true
            })
            table.insert(embMessage.fields, {
                name = "SpielerName",
                value = playerName,
                inline = true
            })
        end

        if messageObject.OffenderId then
            local offenderName = GetPlayerName(messageObject.OffenderId)
            table.insert(embMessage.fields, {
                name = "TäterId",
                value = messageObject.OffenderId,
                inline = true
            })
            table.insert(embMessage.fields, {
                name = "TäterName",
                value = offenderName,
                inline = true
            })
        end

        if messageObject.KillerId and messageObject.KillerId ~= 0 then
            local killerName = GetPlayerName(messageObject.KillerId)
            table.insert(embMessage.fields, {
                name = "KillerId",
                value = messageObject.KillerId,
                inline = true
            })
            table.insert(embMessage.fields, {
                name = "KillerName",
                value = killerName,
                inline = true
            })
        end

        -- Add PlayerName if it exists and PlayerId was not present (to avoid duplication).
        if messageObject.PlayerName and not messageObject.PlayerId then
            table.insert(embMessage.fields, {
                name = "SpielerName",
                value = messageObject.PlayerName,
                inline = true
            })
        end

        -- The main log message content should always be at the end.
        table.insert(embMessage.fields, {
            name = "LogMessage",
            value = messageObject.Message
        })

        -- Encode the embed message into JSON format required by Discord.
        local jsonMessage = json.encode(
            {
                embeds = {
                    embMessage
                }
            }
        )

        -- Perform the HTTP request to send the webhook.
        -- Includes basic error handling for failed requests.
        PerformHttpRequest(webhookUrl, function(error, text, header)
            if error ~= 0 then -- 0 means success in FiveM's PerformHttpRequest
                print(string.format("Warning: Failed to send event webhook to %s. Error code: %d, Response: %s", webhookUrl, error, text))
            end
        end, "POST", jsonMessage, {["Content-Type"] = "application/json"})
    end
end