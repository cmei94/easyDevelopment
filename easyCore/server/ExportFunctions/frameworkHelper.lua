if not EasyCore then
    EasyCore={}
end

--Callbacks
---Calback for client for get special player server id
---@param source number
---@param cb any
---@param id number
---@return table|boolean
FRAMEWORK.RegisterServerCallback("EasyCore:GetPlayerData", function(source, cb, id)
    local result = EasyCore.FrameworkHelper.GetPlayerData(id)
    return cb(result)
end)

--- Callback for usergroup by id
---@param source number
---@param cb boolean|string
---@param id number
FRAMEWORK.RegisterServerCallback('EasyCore:GetUserGroup', function(source, cb, id)
    local xPlayer=EasyCore.FrameworkHelper.GetPlayerData(id)
    local result=false
    if xPlayer then
        result=xPlayer.GetUserGroup()
    end
    return cb(result)
end)

FRAMEWORK.RegisterServerCallback('EasyCore:GetPlayerLicenses', function(source, cb, id)
    local p = promise.new()
    TriggerEvent('esx_license:getLicenses', source, function(licenses)
        p:resolve(licenses)
    end)
    local result=Citizen.Await(p)
    return cb(result)
end)

--Framework FrameworkHelper
EasyCore.FrameworkHelper={}

EasyCore.FrameworkHelper.Framework=FRAMEWORK

---Get player data
---@param id number
---@return table|boolean
EasyCore.FrameworkHelper.GetPlayerData=function (id)
    local result = FRAMEWORK.GetPlayerFromId(id)
    if result then
        return result
    else
        return false
    end
end

---Get players data
---@return  table|boolean
EasyCore.FrameworkHelper.GetPlayersData=function ()
    local result = FRAMEWORK.GetExtendedPlayers()
    if result or EasyCore.Utils.CheckTableCountNotZero(result) then
        return result
    else
        return false
    end
end

---Get players data
---@param jobs table
---@return  table|boolean
EasyCore.FrameworkHelper.GetJobsOnDutyCount=function (jobs)
    local xPlayers = FRAMEWORK.GetExtendedPlayers()
    local result={}
    for k, v in pairs(jobs) do
        EasyCore.Utils.GetOrCreate(result, v, 0)
    end
    if jobs or EasyCore.Utils.CheckTableCountNotZero(jobs) or xPlayers or EasyCore.Utils.CheckTableCountNotZero(xPlayers) then
        for k,v in pairs(xPlayers) do
            if EasyCore.Utils.Contains(jobs, v.job.name) then
                result[v.job.name]=EasyCore.Utils.GetOrCreate(result, v.job.name, 0)+1
            end
        end
    end
    return result
end

