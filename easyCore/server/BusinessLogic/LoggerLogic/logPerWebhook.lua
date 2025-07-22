--- Summary: Creates a JSON-formatted message (Discord embed) for a webhook based on message type.
---@param ressourceName string The name of the resource generating the log.
---@param requestId string A unique identifier for the request/log entry.
---@param message string The actual log message content.
---@param messageType string The type of message ('error', 'warning', 'info', 'debug').
---@return string The JSON string representing the Discord embed message.
function CreateWebhookMessage(ressourceName, requestId, message, messageType)
    local currentTime = os.time()
    local now = os.date('%d-%m-%Y %H:%M:%S', currentTime)

    local titlePrefix = ""
    local color = Config.Logger.Color["debug"] -- Default color to debug

    -- Set title prefix and color based on the message type.
    if messageType == 'error' then
        titlePrefix = "Error in "
        color = Config.Logger.Color["error"]
    elseif messageType == 'warning' then
        titlePrefix = "Warning in "
        color = Config.Logger.Color["warning"]
    elseif messageType == 'info' then
        titlePrefix = "Info in "
        color = Config.Logger.Color["info"]
    else -- 'debug' or any other unexpected type
        titlePrefix = "Debug in "
        color = Config.Logger.Color["debug"]
    end

    -- Return the JSON encoded string for the Discord embed.
    return json.encode(
        {embeds={
                {
                    author={ name=Config.Logger.AuthorName },
                    title=titlePrefix..ressourceName,
                    color=color,
                    fields={
                        {
                            name="RequestId",
                            value=requestId,
                            inline=true
                        },
                        {
                            name="Timestamp",
                            value=now,
                            inline=true
                        },
                        {
                            name= "LogMessage",
                            value= message
                        },
                    }
                }
            }
        }
    )
end

--- Summary: Sends a pre-formatted JSON message to a specified webhook URL.
--- Includes basic error handling for the HTTP request.
---@param webhookUrl string The URL of the Discord webhook.
---@param jsonMessage string The JSON formatted message to send.
function SendLogPerWebhook(webhookUrl, jsonMessage)
    -- Perform the HTTP request to send the webhook.
    PerformHttpRequest(webhookUrl, function(error, text, header)
        if error ~= 0 then -- 0 means success in FiveM's PerformHttpRequest.
            print(string.format("Warning: Failed to send webhook to %s. Error code: %d, Response: %s", webhookUrl, error, text))
        end
    end, "POST", jsonMessage, {["Content-Type"]="application/json"})
end