if not EasyCore then
    EasyCore={}
end
    
--FrameWorkHelper
EasyCore.FrameworkHelper={}

EasyCore.FrameworkHelper.Framework=FRAMEWORK

---call callback for user Data
---@return table|boolean
EasyCore.FrameworkHelper.GetPlayerData=function()
    local playerData=FRAMEWORK.GetPlayerData()
    if playerData then
        return playerData
    else
        return false
    end
end

---GetPlayerLicenses
---@param id number
---@return boolean|table
EasyCore.FrameworkHelper.GetPlayerLicenses=function()
    local id=GetPlayerServerId(PlayerId())
    if not id or id==0 then
        return false
    end
    local p = promise.new()
    FRAMEWORK.TriggerServerCallback('EasyCore:GetPlayerLicenses', function(result) 
        p:resolve(result)
    end, id)
    local result=Citizen.Await(p)
    return result
end

---Check player job
---@param jobGrades table
---@return boolean
EasyCore.FrameworkHelper.CheckJob=function(jobGrades)
    if not EasyCore.Utils.CheckTableCountNotZero(jobGrades) then
        return true
    end
    local playerData=EasyCore.FrameworkHelper.GetPlayerData()
    if playerData and playerData.job and playerData.job.name and playerData.job.grade then
        local playerJob=playerData.job.name
        local playerGrade=playerData.job.grade
        return EasyCore.FrameworkHelper.ContainsJobGrade( playerJob, playerGrade, jobGrades )
    end
    return false
end

---Contains player job and player jobGrade is in table format{["jobname"]=grade}
---@param playerJob string
---@param playerJobGrade number
---@param permittedJobGrades table
---@return boolean
EasyCore.FrameworkHelper.ContainsJobGrade=function(playerJob,playerJobGrade, permittedJobGrades)
    if not playerJob or not playerJobGrade then
        EasyCore.Logger.LogWarning("easyCore","easyCore",("%s: Call %s: playerJob or playerJobGrade is not set!"):format(GetCurrentResourceName(), "EasyCore.FrameworkHelper.ContainsJobGrade()"))
        return false
    end
    for job,grade in pairs(permittedJobGrades) do
        if job == playerJob and playerJobGrade >= grade then
            return true
        end
    end
    return false
end

---Check player group
---@param groups table
---@return boolean
EasyCore.FrameworkHelper.CheckGroup=function(groups)
    if not EasyCore.Utils.CheckTableCountNotZero(groups) then
        return true
    end
    local userGroup=EasyCore.FrameworkHelper.GetUserGroup(GetPlayerServerId(PlayerId()))
    
    if userGroup and EasyCore.Utils.Contains(groups, userGroup) then
        return true
    end
    return false
end

---GetUserGroup
---@param id number
---@return boolean|string
EasyCore.FrameworkHelper.GetUserGroup=function(id)
    if not id then
        return false
    end
    local p = promise.new()
    FRAMEWORK.TriggerServerCallback('EasyCore:GetUserGroup', function(result) 
        p:resolve(result)
    end, id)
    local result=Citizen.Await(p)
    return result
end

