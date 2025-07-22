EasyLog = {}

-- Register a server event for logging messages.
RegisterServerEvent('easyCore:Logger:WriteLog')
--- Summary: Event handler for 'easyCore:Logger:WriteLog' event.
--- Calls the main EasyLog.WriteLog function to process the log.
---@param ressourceName string The name of the resource sending the log.
---@param requestId string A unique identifier for the request/log entry.
---@param message string The log message content.
---@param messageType string The type of message ('error', 'debug', 'info', 'warning').
AddEventHandler('easyCore:Logger:WriteLog', function(ressourceName, requestId, message, messageType)
    EasyLog.WriteLog(ressourceName, requestId, message, messageType)
end)

--- Summary: Helper function to get a numerical weight for a given log level.
--- Used for comparing log levels (e.g., to determine if a message should be logged based on configuration).
---@param level string The log level (e.g., 'debug', 'info', 'warning', 'error').
---@return number The numerical weight of the log level, or 0 if unknown.
local function getLogLevelWeight(level)
    -- Using a table for faster lookups of log level weights.
    local levels = {
        ["debug"] = 1,
        ["info"] = 2,
        ["warning"] = 3,
        ["error"] = 4
    }
    return levels[level] or 0 -- Return 0 for unknown levels to treat them as 'lower'.
end

--- Summary: Main function to write logs, performing validation and dispatching to different outputs.
--- Checks for valid message log level and blacklist violations.
---@param ressourceName string The name of the resource generating the log.
---@param requestId string A unique identifier for the request/log entry.
---@param message string The actual log message content.
---@param messageLogLevel string The log level of the message ('error', 'debug', 'info', 'warning').
EasyLog.WriteLog = function(ressourceName, requestId, message, messageLogLevel)
    -- Validate the messageLogLevel.
    if messageLogLevel and type(messageLogLevel) == "string" then
        messageLogLevel = messageLogLevel:lower()
        local isValid = false
        -- Check if the provided log level is one of the configured valid levels.
        for k, v in pairs(Config.Logger.MessageLogLevels) do
            if v == messageLogLevel then
                isValid = true
                break
            end
        end
        if not isValid then
            -- Throw an error if the message type is invalid or null.
            error("massageType is false type or null!")
        end
    else
        -- Throw an error if messageType is not a string or is null.
        error("massageType is false type or null!")
    end

    -- Check if the log message contains any blacklisted items.
    if EasyCore.Utils.CheckOnceStringItemOfTableExistsInString(Config.Blacklists.LogMessageBlackList, message, false) then
        -- If blacklisted content is found, log a warning about it using the same logging system.
        ExecutDifferentLogs(requestId, "easyCore", ("A violation of Config.Blacklists.LogMessageBlackList was detected in message: %s from resource: %s"):format(message, ressourceName), "warning")
    end

    -- If server logging is enabled in the config, proceed to execute different logging outputs.
    if Config.Logger.ServerLog.Enable then
        ExecutDifferentLogs(requestId, ressourceName, message, messageLogLevel)
    end
end

--- Summary: Dispatches the log message to various outputs (log files, console, webhooks) based on configuration.
---@param requestId string The unique identifier for the log entry.
---@param ressourceName string The name of the resource.
---@param message string The log message content.
---@param messageLogLevel string The log level of the message.
function ExecutDifferentLogs(requestId, ressourceName, message, messageLogLevel)
    local originalRequestId = requestId -- Store the original requestId to check if it was missing.
    -- If requestId is not provided, set it to "n.a." (not applicable).
    if not requestId then
        requestId = "n.a."
    end

    -- Create the formatted log message string.
    local messageCreated = CreateLogMessage(ressourceName, requestId, message, messageLogLevel)
    if messageCreated and messageLogLevel then
        -- Write to individual resource log file if enabled and log level permits.
        if Config.Logger.ServerLog.LogFile.Enable then
            WriteMessageToLogFile(ressourceName, messageCreated, messageLogLevel, Config.Logger.ServerLog.LogFile.LogLevel)
        end
        -- Write to server console if log level permits.
        WriteServerConsoleLogMessage(messageCreated, messageLogLevel)
        -- Write to total log file if enabled and log level permits.
        if Config.Logger.ServerLog.TotalLog.Enable then
            WriteMessageToLogFile(Config.Logger.ServerLog.TotalLog.Name, messageCreated, messageLogLevel, Config.Logger.ServerLog.TotalLog.LogLevel)
        end

        -- Webhook Logic: Check if webhooks are enabled and message level meets the configured webhook level.
        local webhookLogLevelWeight = getLogLevelWeight(Config.Logger.WebhookLogLevel)
        local messageLogLevelWeight = getLogLevelWeight(messageLogLevel)

        if Config.Logger.ServerLog.EnableWebhooks and messageLogLevelWeight >= webhookLogLevelWeight then
            -- Check if a specific webhook URL is configured for the resource.
            if Config.Logger.Webhooks[ressourceName] and Config.Logger.Webhooks[ressourceName] ~= "" then
                local webhookUrl = Config.Logger.Webhooks[ressourceName]
                local embedJson = CreateWebhookMessage(ressourceName, requestId, message, messageLogLevel)
                SendLogPerWebhook(webhookUrl, embedJson)
            else
                -- Print an error if the webhook URL is missing or empty for the resource.
                print("Error: Webhook URL is empty or no webhook registered in 'config-webhooks.lua' of easyLogs for resource: " .. ressourceName)
            end
        end
    end

    -- Only throw an error if the Request ID was originally missing (nil).
    if originalRequestId == nil then
        error("Missing Request ID. See log files for details: " .. message .. " " .. ressourceName)
    end
end

--- Summary: Helper function to determine if a log message should be written based on its level and the configured minimum log level.
---@param messageLogLevel string The log level of the message to be written.
---@param configuredLogLevel string The minimum log level configured for the output.
---@return boolean True if the message should be written, false otherwise.
local function shouldWriteLog(messageLogLevel, configuredLogLevel)
    local messageWeight = getLogLevelWeight(messageLogLevel)
    local configWeight = getLogLevelWeight(configuredLogLevel)
    return messageWeight >= configWeight
end

--- Summary: Writes a formatted log message to a specific log file.
--- Only writes if the message's log level meets the configured minimum log level for the file.
---@param fileName string The base name of the log file (e.g., resource name).
---@param message string The formatted log message string.
---@param messageLogLevel string The log level of the message.
---@param logLevel string The configured minimum log level for this file.
function WriteMessageToLogFile(fileName, message, messageLogLevel, logLevel)
    if shouldWriteLog(messageLogLevel, logLevel) then
        WriteToFile(fileName, message)
    elseif not (getLogLevelWeight(logLevel) > 0) then -- Check if the configured LogLevel is invalid (weight 0).
        print("Error: Invalid Config.Logger.ServerLog.LogFile.LogLevel configuration!")
    end
end

--- Summary: Appends a message to a text file in the resource's 'logs' directory.
--- The file name includes the resource name and the current date.
---@param ressourceName string The name of the resource (used in filename).
---@param message string The message string to write.
function WriteToFile(ressourceName, message)
    local currentTime = os.time()
    local now = os.date('%d-%m-%Y', currentTime)
    local path = GetResourcePath(GetCurrentResourceName())
    -- Normalize path to handle potential double slashes and append the logs directory.
    path = path:gsub('//', '/') .. '/logs/'
    -- Open the file in append mode, creating it if it doesn't exist.
    local file = io.open(path .. ressourceName .. "_" .. now .. ".txt", "a+")
    file:write(message, "\n") -- Write the message followed by a newline.
    file:close() -- Close the file.
end

--- Summary: Prints a log message to the server console.
--- Only prints if the message's log level meets the configured minimum log level for the console.
---@param message string The formatted log message string.
---@param messageLogLevel string The log level of the message.
function WriteServerConsoleLogMessage(message, messageLogLevel)
    local consoleLogLevel = Config.Logger.ServerLog.Console.LogLevel
    if shouldWriteLog(messageLogLevel, consoleLogLevel) then
        print(message)
    elseif not (getLogLevelWeight(consoleLogLevel) > 0) then -- Check if the configured LogLevel is invalid.
        print("Error: Invalid Config.ServerLog.Console.LogLevel configuration!")
    end
end

--- Summary: Creates a standardized log message string with timestamp, request ID, resource name, and log level prefix.
---@param ressourceName string The name of the resource.
---@param requestId string The unique identifier for the request/log entry.
---@param message string The raw log message content.
---@param messageLogLevel string The log level of the message.
---@return string The formatted log message string.
function CreateLogMessage(ressourceName, requestId, message, messageLogLevel)
    local currentTime = os.time()
    local now = os.date('%d-%m-%Y %H:%M:%S', currentTime)
    local prefix = "Debug" -- Default prefix for debug level messages.

    -- Set the prefix based on the message log level.
    if messageLogLevel == 'error' then
        prefix = "Error"
    elseif messageLogLevel == 'warning' then
        prefix = "Warning"
    elseif messageLogLevel == 'info' then
        prefix = "Info"
    end
    -- Format the log message string.
    return now .. " || " .. requestId .. " || " .. ressourceName .. " || " .. prefix .. ": " .. message
end