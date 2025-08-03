--- Summary: Creates a Discord embed object based on message type.
--- It no longer returns a full JSON string, but just the embed object.
---@param ressourceName string The name of the resource generating the log.
---@param requestId string A unique identifier for the request/log entry.
---@param message string The actual log message content.
---@param messageType string The type of message ('error', 'warning', 'info', 'debug').
---@return table The Lua table representing the Discord embed.
function CreateWebhookMessage(ressourceName, requestId, message, messageType)
    local currentTime = os.time()
    local now = os.date('%d-%m-%Y %H:%M:%S', currentTime)

    local titlePrefix = ""
    local color = Config.Logger.Color["debug"] -- Default color

    if messageType == 'error' then
        titlePrefix = "Error in "
        color = Config.Logger.Color["error"]
    elseif messageType == 'warning' then
        titlePrefix = "Warning in "
        color = Config.Logger.Color["warning"]
    elseif messageType == 'info' then
        titlePrefix = "Info in "
        color = Config.Logger.Color["info"]
    else -- 'debug'
        titlePrefix = "Debug in "
        color = Config.Logger.Color["debug"]
    end

    -- Return the embed object.
    return {
        author = { name = Config.Logger.AuthorName },
        title = titlePrefix .. ressourceName,
        color = color,
        fields = {
            {
                name = "RequestId",
                value = requestId,
                inline = true
            },
            {
                name = "Timestamp",
                value = now,
                inline = true
            },
            {
                name = "LogMessage",
                value = message
            },
        }
    }
end

--- Summary: Queues a log message to be sent via the central webhook handler.
--- It no longer sends the HTTP request directly.
---@param webhookUrl string The URL of the Discord webhook.
---@param embedObject table The embed object to be sent.
function SendLogPerWebhook(webhookUrl, embedObject)
    QueueWebhookMessage(webhookUrl, embedObject)
end