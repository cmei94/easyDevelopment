if not EasyCore then
    EasyCore={}
end

--Utils
if not EasyCore.Utils then
    EasyCore.Utils={}
end

EasyCore.Utils.Switch = function(case)
    return function(cases)
        local f = cases[case] or cases.default
        if f then return f() end
    end
end

---Get RessourcePath
---@param ressourceName string
---@return string|boolean
EasyCore.Utils.GetPathByRessourceName = function(ressourceName)
    if ressourceName then
        local path = GetResourcePath(ressourceName)
        path = path:gsub('//', '/')..'/'
        return path
    end
    return false
end

---clone table
---@param orig table
---@return table
EasyCore.Utils.DeepClone = function(orig)
    return DeepClone(orig)
end

---generate guid
---@return string
EasyCore.Utils.Guid = function()
    return Guid()
end

---count items in table
---@param list table
---@return integer
EasyCore.Utils.ListCount = function(list)
    return ListCount(list)
end

---check table is not null or empty
---@param table table
---@return boolean
EasyCore.Utils.CheckTableCountNotZero = function(table)
    return CheckTableCountNotZero(table)
end

---check itrem is in table
---@param table table
---@param item any
---@return boolean
EasyCore.Utils.Contains = function(table, item)
    return Contains(table, item)
end

---get value by key
---@param table any
---@param item any
---@return boolean|any
EasyCore.Utils.GetValueByKey = function(table, item)
    return GetValueByKey(table, item)
end

---Check once of table items is in text
---@param table table<string>
---@param text string
---@return boolean
EasyCore.Utils.CheckOnceStringItemOfTableExistsInString = function (table, text, ignoreCase)
    return CheckOnceStringItemOfTableExistsInString(table, text, ignoreCase)
end

---return not nil table index
---@param table table
---@param key any
---@param defaultValue any
---@return any
EasyCore.Utils.GetOrCreate = function (table, key, defaultValue)
    if not table[key] then
        table[key]=defaultValue
    end
    return table[key]
end

---data encrypt
---@param data string
---@param key string
---@return any
EasyCore.Utils.Encrypt=function (data, key)
    return json.decode(XorEncrypt(data, key))
end

---comment
---@param encryptedData any
---@param key any
---@return string|boolean
EasyCore.Utils.Decrypt=function (encryptedData, key)
    return XorDecrypt(json.encode(encryptedData), key)
end

--#region special for server or client
if IsDuplicityVersion() then--if true it is server side
    --#region server utils
    --#region server time utils
    EasyCore.Utils.Time={}

    --- Function to start a stopwatch.
    ---@return number
    EasyCore.Utils.Time.StartStopwatch=function()
        return os.clock()
    end

    --- Retrieve the elapsed time since the start of the stopwatch.
    ---@param startTime number
    ---@return number
    EasyCore.Utils.Time.GetElapsedTime=function(startTime)
        return (os.clock() - startTime) * 1000 -- in Millisekunden umrechnen
    end

    ---Checks elapsed time since start is greater equal duration in hours
    ---@param timestamp osdate os timestamp
    ---@param durationInHours number hours
    ---@return boolean
    EasyCore.Utils.Time.IsHoursElapsedSinceStart=function(timestamp, durationInHours)
        local secTimer=durationInHours*60*60
        local now=os.time()
        local actualTimeSubstractTime=os.date("*t",now-secTimer)
        if(actualTimeSubstractTime~=nil and timestamp~=nil)then
            if os.time(actualTimeSubstractTime)>=os.time(timestamp) then
                return true
            end                                       
        end
        return false  -- in Millisekunden umrechnen
    end
    --#endregion server time utils
    --#endregion server utils
else
    --#region client utils
    --TODO: prüfen ob unter fiveM genauso
    EasyCore.Utils.PlayAnimation=function(ped, animation, dict, enumFlag, duration)
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(Config.Timeout.TimeUntilTryAgainInMs)
        end
        TaskPlayAnim(ped, dict, animation, 1.0, -1, duration, enumFlag, 0, 0, 0, 0)
        Citizen.Wait(duration)
        ClearPedTasks(ped)
        RemoveAnimDict(dict)
    end

    ---comment
    ---@param closestDistance number
    ---@return table --PlayerIds
    EasyCore.Utils.GetNearestPlayers=function(closestDistance)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed, true, true)
        local closestPlayers = {}

        for _, player in pairs(GetActivePlayers()) do
            local target = GetPlayerPed(player)

            if target ~= playerPed then
                local targetCoords = GetEntityCoords(target, true, true)
                local distance = #(targetCoords - coords)

                if distance < closestDistance then
                    table.insert(closestPlayers, player)
                end
            end
        end
        return closestPlayers
    end

    EasyCore.Utils.Keys=Config.Keys
    --#endregion client utils
end
--#endregion