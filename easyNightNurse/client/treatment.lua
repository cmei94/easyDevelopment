---
--- Contains the logic for the actual treatment process.
--- Includes healing, reviving, animations, NPC control, and payment.
---

--=================================================================================
--== TREATMENT PROCESSES (ENTRY POINTS)
--=================================================================================

---
--- Starts the healing process for an injured player.
---@param requestId string The unique ID for this treatment process.
---@param nurseKey string The key of the nurse station.
---@param nurse table The configuration table for the nurse.
---
function StartHealing(requestId, nurseKey, nurse)
    ESX.TriggerServerCallback('easyNightNurse:checkMoney', function(hasEnoughMoney)
        if not hasEnoughMoney then
            EasyCore.Notifications.Error("Night Nurse", "You don't have enough money for the treatment.", 5000)
            ResetTreatmentState()
            return
        end

        local bedKey = GetFreeBed(nurseKey)
        
        if bedKey then
            local bed = nurse.TreatmentPositions[bedKey]
            PerformBedTreatment(requestId, nurseKey, bedKey, nurse, bed, false) -- isRevive = false
        else
            EasyCore.Notifications.Warning("Night Nurse", "There are no free beds. Please wait a moment.", 6000)
            ResetTreatmentState()
        end
    end, nurse.HealingPrice)
end

---
--- Starts the revival process for a dead/downed player.
---@param requestId string The unique ID for this treatment process.
---@param nurseKey string The key of the nurse station.
---@param nurse table The configuration table for the nurse.
---
function StartRevive(requestId, nurseKey, nurse)
    ESX.TriggerServerCallback('easyNightNurse:checkMoney', function(hasEnoughMoney)
        if not hasEnoughMoney then
            EasyCore.Notifications.Error("Night Nurse", "You don't have enough money for the revival.", 5000)
            ResetTreatmentState()
            return
        end
        
        local bedKey = GetFreeBed(nurseKey)

        if bedKey then
            local bed = nurse.TreatmentPositions[bedKey]
            StopAllScreenEffects()
            PerformBedTreatment(requestId, nurseKey, bedKey, nurse, bed, true) -- isRevive = true
        else
            EasyCore.Notifications.Warning("Night Nurse", "There are no free beds. Please wait a moment.", 6000)
            ResetTreatmentState()
        end
    end, nurse.RevivePrice)
end

--=================================================================================
--== CORE TREATMENT WORKFLOW
--=================================================================================

---
--- Executes the entire treatment sequence in the bed (healing or revival).
---@param requestId string The unique ID for this treatment process.
---@param nurseKey string The key of the nurse station.
---@param bedKey string The key of the assigned bed.
---@param nurse table The configuration table for the nurse.
---@param bed table The configuration table for the bed.
---@param isRevive boolean Indicates whether this is a revival.
---
function PerformBedTreatment(requestId, nurseKey, bedKey, nurse, bed, isRevive)
    local playerPed = PlayerPedId()
    local price = isRevive and nurse.RevivePrice or nurse.HealingPrice
    local healTime = bed.HealTime

    EasyCore.Logger.LogDebug(RessourceName, requestId, ("Starting treatment in bed %s for nurse %s. IsRevive: %s"):format(bedKey, nurseKey, isRevive))

    -- 1. Freeze player and transport to bed
    FreezePlayer(true)
    DoScreenFadeOut(500)
    Wait(1000)
    
    exports.rprogress:Start("You are being taken to a bed...", bed.TransportTimeToBed or 5000)

    TeleportToBed(playerPed, bed)
    PlayAnimation(requestId, playerPed, bed.BedPatientAnimation.animDict, bed.BedPatientAnimation.animName, bed.BedPatientAnimation.flag)
    Wait(500)
    DoScreenFadeIn(500)
    
    -- 2. Create doctor NPC and move them to the bed
    local doctorPed = nil
    if bed.UseDoctorNPC and bed.Doctor and bed.Doctor.Model then
        EasyCore.Notifications.Info("Night Nurse", "A doctor is on their way to you.", 4000)
        doctorPed = CreateAndMoveDoctor(requestId, bed)
    end
    
    -- 3. Play animations
    local doctorAnim = isRevive and bed.Doctor.ReviveAnimation or bed.Doctor.HealAnimation
    if doctorPed then
        PlayAnimation(requestId, doctorPed, doctorAnim.animDict, doctorAnim.animName, doctorAnim.flag)
    end

    -- 4. Show progress bar for the treatment
    local progressLabel = isRevive and "Reviving..." or "Healing..."
    exports.rprogress:Start(progressLabel, healTime)

    -- 5. Stop animations and heal/revive the player
    
    if doctorPed then ClearPedTasks(doctorPed) end

    if isRevive then
        Config.ClientFunctions.RevivePlayer(PlayerId())
    else
        Config.ClientFunctions.HealPlayer(PlayerId())
    end

    -- 6. Trigger server-side payment
    TriggerServerEvent("easyNightNurse:payMoney", requestId, price, nurse.Label)
    if Config.Features.EnableSetMoneyToSociety then
        TriggerServerEvent("easyNightNurse:payToSociety", requestId, price, Config.Features.PaySocieties)
    end

    -- 7. Make the doctor walk back and then delete them
    Citizen.CreateThread(function()
        if doctorPed then
            EasyCore.Notifications.Info("Night Nurse", "The doctor is handling the paperwork. You can leave shortly.", 4000)
            MoveDoctorBackAndDelete(requestId, doctorPed, bed.Doctor.WalkPositions)
        end
    end)

    -- 8. Show progress bar for exit transport
    exports.rprogress:Start("Treatment complete, you are being discharged...", bed.TransportTimeToExit or 5000)
    
    DoScreenFadeOut(500)
    ClearPedTasks(playerPed)
    Wait(1000)
    TeleportToExit(playerPed, bed)
    DoScreenFadeIn(500)
    FreezePlayer(false)

    -- 9. Free the bed on the server and reset the client state
    TriggerServerEvent("easyNightNurse:freeBed", requestId, nurseKey, bedKey)
    ResetTreatmentState()
end

--=================================================================================
--== HELPER FUNCTIONS (UTILITIES)
--=================================================================================

---
--- Freezes or unfreezes the player's controls.
---@param shouldFreeze boolean true to freeze, false to unfreeze.
---
function FreezePlayer(shouldFreeze)
    FreezeEntityPosition(PlayerPedId(), shouldFreeze)
end

---
--- Teleports the player to the treatment bed.
---@param playerPed number The handle of the player's ped.
---@param bedConfig table The configuration of the target bed.
---
function TeleportToBed(playerPed, bedConfig)
    SetEntityCoords(playerPed, bedConfig.BedPositionAndHeading.x, bedConfig.BedPositionAndHeading.y, bedConfig.BedPositionAndHeading.z)
    SetEntityHeading(playerPed, bedConfig.BedPositionAndHeading.w)
end

---
--- Teleports the player to the exit coordinates.
---@param playerPed number The handle of the player's ped.
---@param bedConfig table The configuration of the bed the player is coming from.
---
function TeleportToExit(playerPed, bedConfig)
    SetEntityCoords(playerPed, bedConfig.ExitCoord.x, bedConfig.ExitCoord.y, bedConfig.ExitCoord.z)
end

---
--- Creates the doctor NPC and moves them along the path to the player.
--- Includes a fallback teleport in case the NPC gets stuck.
---@param requestId string The unique ID for this treatment process.
---@param bedConfig table The configuration of the bed, including doctor info.
---@return number The handle of the created doctor ped.
---
function CreateAndMoveDoctor(requestId, bedConfig)
    local model = GetHashKey(bedConfig.Doctor.Model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

    local firstPos = bedConfig.Doctor.WalkPositions[1]
    local doctorPed = CreatePed(4, model, firstPos.position.x, firstPos.position.y, firstPos.position.z, firstPos.heading, false, true)
    
    for i = 2, #bedConfig.Doctor.WalkPositions do
        local posData = bedConfig.Doctor.WalkPositions[i]
        TaskGoToCoordAnyMeans(doctorPed, posData.position.x, posData.position.y, posData.position.z, 1.0, 0, false, 786603, 0xbf800000)
        
        local timeoutCounter = 0
        while #(GetEntityCoords(doctorPed, true) - posData.position) > 1.5 do
            Wait(100)
            timeoutCounter = timeoutCounter + 1
            if timeoutCounter > 150 then -- Teleport after 15 seconds
                EasyCore.Logger.LogWarning(RessourceName, requestId, "Doctor NPC got stuck, teleporting to destination.")
                SetEntityCoords(doctorPed, posData.position.x, posData.position.y, posData.position.z)
                break
            end
        end
        
        if posData.heading then
            TaskStandStill(doctorPed, -1)
            SetEntityHeading(doctorPed, posData.heading)
        end
    end
    
    return doctorPed
end

---
--- Makes the doctor walk back along the path in reverse and deletes them at the end.
---@param requestId string The unique ID for this treatment process.
---@param ped number The handle of the doctor ped.
---@param walkPositions table The list of waypoints.
---
function MoveDoctorBackAndDelete(requestId, ped, walkPositions)
    for i = #walkPositions - 1, 1, -1 do
        local posData = walkPositions[i]
        TaskGoToCoordAnyMeans(ped, posData.position.x, posData.position.y, posData.position.z, 1.0, 0, false, 786603, 0xbf800000)
        
        local timeoutCounter = 0
        while #(GetEntityCoords(ped, true) - posData.position) > 1.5 do
            Wait(100)
            timeoutCounter = timeoutCounter + 1
            if timeoutCounter > 150 then
                EasyCore.Logger.LogWarning(RessourceName, requestId, "Doctor NPC got stuck on return path, teleporting.")
                SetEntityCoords(ped, posData.position.x, posData.position.y, posData.position.z)
                break
            end
        end
    end
    DeleteEntity(ped)
end

---
--- Helper function to play an animation on a ped.
---@param requestId string The unique ID for this process (for error logging).
---@param ped number The handle of the ped.
---@param animDict string The animation dictionary.
---@param animName string The name of the animation.
---@param flag number The animation flag.
---
function PlayAnimation(requestId, ped, animDict, animName, flag)
    RequestAnimDict(animDict)
    local counter = 0
    while not HasAnimDictLoaded(animDict) do
        Wait(50)
        counter = counter + 1
        if counter > 100 then -- Timeout after 5 seconds
            EasyCore.Logger.LogError(RessourceName, requestId, "Could not load animation dictionary: " .. animDict)
            return
        end
    end
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, flag, 0, false, false, false)
end