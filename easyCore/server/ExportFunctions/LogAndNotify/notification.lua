if not EasyCore then
    EasyCore={}
end

--Notifications
EasyCore.Notifications = {}

---show success notification green
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Success=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'success', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, "success", duration)
    end
end

---show info notification blue
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Info=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'info', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, "info", duration)
    end
end

---show warning notification yellow
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Warning=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'warning', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, 'info', duration)
    end
end

---show error notification red
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Error=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'error', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, 'error', duration)
    end
end

---show phonemessage  notification orange
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.PhoneMessage=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'phonemessage', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, 'info', duration)
    end
end

---show neutral notification grey
---@param id number playerID
---@param title string
---@param message string
---@param duration number time in ms
---@param playSound boolean
EasyCore.Notifications.Neutral=function (id, title, message, duration, playSound)
    if Config.UsedScripts.Notifications=="okokNotify" then
        exports['okokNotify']:Alert(id, title, message, duration, 'neutral', playSound)
    else
        FRAMEWORK.ShowNotification(id, message, 'info', duration)
    end
end

