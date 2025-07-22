-- Only run the file deletion logic if enabled in the configuration.
if Config.Logger.ServerLog.EnableAutoLogFileDelete then
    Citizen.CreateThread(function ()
        Citizen.Wait(5000) -- Wait 5 seconds before starting the deletion process.
        
        -- Get the configured time for file deletion in hours.
        local timeForDeleteInHours = Config.Logger.ServerLog.EnableAutoLogFileDeleteTimeInHours

        -- Ensure that the deletion time is at least 24 hours.
        if timeForDeleteInHours and timeForDeleteInHours < 24 then
            timeForDeleteInHours = 24
        elseif not timeForDeleteInHours then -- If not configured, default to 24 hours.
            timeForDeleteInHours = 24
        end

        -- Construct the log file path.
        local path = GetResourcePath(GetCurrentResourceName())
        -- Normalize path to handle potential double slashes and append the logs directory.
        path = path:gsub('//', '/') .. '/logs/'

        -- Convert hours to seconds for the DeleteOlderFiles function.
        EasyCore.Folder.DeleteOlderFiles(path, timeForDeleteInHours * 60 * 60)
    end)
end