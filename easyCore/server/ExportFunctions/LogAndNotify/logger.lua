if not EasyCore then
    EasyCore={}
end

EasyCoreRequestId="ServerSide "..Guid()

--Logger
EasyCore.Logger={}


---write log in log level debug
---@param ressourceName string
---@param requestId string
---@param message string
EasyCore.Logger.LogDebug=function (ressourceName,requestId,message)
    EasyLog.WriteLog(ressourceName,requestId,message,"debug")
end

---write log in log level info
---@param ressourceName string
---@param requestId string
---@param message string
EasyCore.Logger.LogInfo=function (ressourceName,requestId,message)
    EasyLog.WriteLog(ressourceName,requestId,message,"info")
end 

---write log in log level warning
---@param ressourceName string
---@param requestId string
---@param message string
EasyCore.Logger.LogWarning=function (ressourceName,requestId,message)
    EasyLog.WriteLog(ressourceName,requestId,message,"warning")
end

---write log in log level error
---@param ressourceName string
---@param requestId string
---@param message string
EasyCore.Logger.LogError=function (ressourceName,requestId,message)
    EasyLog.WriteLog(ressourceName,requestId,message,"error")
end

---error handler for xpcal exceptions
---@param ressourceName any
---@param requestId any
---@param message any
EasyCore.Logger.ErrorHandler=function (ressourceName,requestId,message)
    EasyLog.WriteLog(requestId,message,"error")
end