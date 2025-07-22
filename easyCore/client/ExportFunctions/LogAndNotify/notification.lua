if not EasyCore then
    EasyCore={}
end


--Notifications
EasyCore.Notifications = {}

---show success notification green
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Success=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'success', playSound)
    else
        FRAMEWORK.ShowNotification(message, "success", duration)
    end
    
end

---show info notification blue
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Info=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'info', playSound)
    else
        FRAMEWORK.ShowNotification(message, "info", duration)
    end
end

---show warning notification yellow
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Warning=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'warning', playSound)
    else
        FRAMEWORK.ShowNotification(message, 'info', duration)
    end
end

---show error notification red
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Error=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'error', playSound)
    else
        FRAMEWORK.ShowNotification(message, 'error', duration)
    end
end

---show phonemessage  notification orange
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.PhoneMessage=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'phonemessage', playSound)
    else
        FRAMEWORK.ShowNotification(message, 'info', duration)
    end
end

---show neutral notification grey
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Neutral=function (title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(title, message, duration, 'neutral', playSound)
    else
        FRAMEWORK.ShowNotification(message, 'info', duration)
    end
end
